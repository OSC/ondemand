class Files
  # TODO: could do streaming instead
  # foreach and ndjson
  def ls(dirpath)
    Pathname.new(dirpath).each_child.map do |path|
      stat(path)
    end.sort_by { |p| p[:directory] ? 0 : 1 }
  end

  def stat(path)
    s = path.stat

    {
      name: path.basename,
      size: s.directory? ? 'dir' : s.size,
      directory: s.directory?,
      date: s.mtime.strftime("%d.%m.%Y"),
      owner: username(s.uid),
      #todo: this value converted here or server side
      mode: s.mode
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
  def username(uid)
    Etc.getpwuid(uid).name
  rescue
    uid
  end
end
