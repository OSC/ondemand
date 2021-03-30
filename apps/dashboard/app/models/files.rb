class Files


  def self.raise_if_cant_access_directory_contents(path)
    # try to actually access directory contents
    # if an exception is raised, we do not have access
    path.each_child.first
  end

  # TODO: could do streaming instead
  # foreach and ndjson
  def ls(dirpath)
    Pathname.new(dirpath).each_child.map do |path|
      Files.stat(path)
    end.sort_by { |p| p[:directory] ? 0 : 1 }
  end

  def self.stat(path)
    path = Pathname.new(path)

    begin
      s = path.stat
    rescue
      # FIXME: this is tricky - what should a copy do with a valid symlink? a move?
      # we should tell people when they have a symlink; also you can't "fix" symlinks... in the files app yet
      s = path.lstat
    end

    # path.stat will not work for a symlink
    # and will raise
    # path.readlink returns string of the target of the symlink
    # if the symlink is broken, could report this
    # could also report the symlink target (if it exists) for every file
    #
    # FIXME: in what other file states will an exception be raised?
    # FIXME: in this case copying, moving, etc. might also be problematic?
    # also we can't do the id here...
    # what if its a socket file?
    {
      id: "dev-#{s.dev}-inode-#{s.ino}",
      name: path.basename,
      size: s.directory? ? 'dir' : s.size,
      human_size: ::ApplicationController.helpers.number_to_human_size(s.size, precision: 3),
      directory: s.directory?,
      date: s.mtime.to_i,
      owner: username(s.uid),
      mode: s.mode,
      dev: s.dev
    }
  end

  #TODO: better cache (like persistent but memory limited)
  #https://www.justinweiss.com/articles/4-simple-memoization-patterns-in-ruby-and-one-gem/
  #
  #
  # def self.top_cities(order_by)
  #   @top_cities ||= Hash.new do |h, key|
  #     h[key] = where(top_city: true).order(key).to_a
  #   end
  #   @top_cities[order_by]
  # end

  # FIXME: cache
  def self.username(uid)
    Etc.getpwuid(uid).name
  rescue
    uid
  end

  def num_files(from, names)
    args = names.map {|n| Shellwords.escape(n) }.join(' ')
    o, e, s = Open3.capture3("find 2>/dev/null #{args} | wc -l", chdir: from)

    # FIXME: handle status error
    o.lines.last.to_i
  end

  # FIXME: timeout when checking for the large size
  def rm_with_progress(from, names, &block)
    files_to_rm = num_files(from, names)

    # progress could show all of the files selected to delete and their status
    # rm -rfv outputs one line per directory/file removed

    # FIXME: if you raise an exception do you lose the Dir.chdir pop?
    Open3.popen3('rm', '-rfv', *names, chdir: from) do |i, o, e, t|
      err_reader = Thread.new { e.read  }

      if block_given?
        o.each_line.with_index { |l, index|
          # percent complete
          block.call(100.0*(index.to_f/files_to_rm))
        }
        o.close

        [t.value, err_reader.value]
      else
        [t.value, err_reader.value]
      end
    end
  end

  def mv_with_progress(from, names, to, &block)
    # mv each file, then rm source files
    steps = num_files(from, names)*2
    args = names + [to]

    # progress could show all of the files selected to delete and their status
    # rm -rfv outputs one line per directory/file removed

    # FIXME: if you raise an exception do you lose the Dir.chdir pop?
    Open3.popen3('mv', '-v', *args, chdir: from) do |i, o, e, t|
      err_reader = Thread.new { e.read  }

      if block_given?
        o.each_line.with_index { |l, index|
          # percent complete
          block.call(100.0*(index.to_f/steps))
        }
        o.close

        [t.value, err_reader.value]
      else
        [t.value, err_reader.value]
      end
    end
  end

  def cp_with_progress(from, names, to, &block)
    # cp each file
    steps = num_files(from, names)
    args = names + [to]

    # progress could show all of the files selected to delete and their status
    # rm -rfv outputs one line per directory/file removed

    # FIXME: if you raise an exception do you lose the Dir.chdir pop?
    Open3.popen3('cp', '-rv', *args, chdir: from) do |i, o, e, t|
      err_reader = Thread.new { e.read  }

      if block_given?
        o.each_line.with_index { |l, index|
          # percent complete
          block.call(100.0*(index.to_f/steps))
        }
        o.close

        [t.value, err_reader.value]
      else
        [t.value, err_reader.value]
      end
    end
  end

  # from is a path, names are the files to copy
  # and to is the destination dir
  #
  # execute rsync, executing the block for each progress event (delimited by \r)
  def rsync(from, names, to, &block)
    to = to.chomp("/") + "/"
    args = rsync_args + names + [to]

    Open3.popen3('rsync', *args, chdir: from) do |i, o, e, t|
      err_reader = Thread.new { e.read  }

      output = ""
      if block_given?
        o.each_line("\r") { |l|
          block.call(l)

          output += l
        }
        o.close

        [t.value, err_reader.value]
      else
        output = o.read
        o.close

        [t.value, err_reader.value]
      end
    end
  end

  # [last_progress_event, err, status]
  def rsync_dryrun(from, names, to)
    to = to.chomp("/") + "/"
    args = rsync_args + names + [to]

    out, err, status = Open3.capture3('rsync', '--dry-run', *args, chdir: from)
    out = out.each_line("\r").to_a.last

    [out, err, status]
  end

  def rsync_args
    %w(-r --info=progress2 --no-inc-recursive --archive --msgs2stderr)
  end
end
