# frozen_string_literal: true

# ClusterTransfer is a class for handling transfers to clusters (see ood_core files adapter).
class ClusterTransfer < Transfer
  validates_each :files do |record, _, files|
    files.each do |k, v|
      # Validate paths in the same way as PosixTransfer for the local filesystem (fs)
      if (record.src_fs == RcloneUtil::LOCAL_FS_NAME) && !AllowlistPolicy.default.permitted?(k.to_s)
        record.errors.add :base,
                          "#{k} is not included under ALLOWLIST_PATH"
      end
      unless (record.dest_fs == RcloneUtil::LOCAL_FS_NAME) && !v.nil? && !AllowlistPolicy.default.permitted?(v.to_s)
        next
      end

      # rm commands are [{ k => nil}] - nil values
      record.errors.add :base,
                        "#{v} is not included under ALLOWLIST_PATH"
    end

    if ['mv', 'cp'].include?(record.action)
      # -> local filesystem
      if record.dest_fs == RcloneUtil::LOCAL_FS_NAME
        conflicts = files.values.select { |f| File.exist?(f) }
        record.errors.add :base, "These files already exist: #{conflicts.join(', ')}" if conflicts.present?
      else
        # local -> cluster
        begin
          existing = record.adapter.ls(record.to).map { |file| File.join(record.to, file[:name]) }
          conflicts = files.values.intersection(existing)
          record.errors.add :base, "These files already exist: #{conflicts.join(', ')}" if conflicts.present?
        rescue StandardError => e
          record.errors.add :base, "Error checking existing files in destination: #{e}"
        end
      end
    end
  end

  attr_accessor :src_fs, :dest_fs, :adapter, :tempfile, :filesizes, :transferred

  class << self
    def transfers
      Transfer.transfers
    end

    def build(action:, files:, src_fs:, dest_fs:, tempfile: nil)
      if files.is_a?(Array)
        # rm action will want to provide an array of files
        # so if it is an Array we convert it to a hash:
        #
        # convert [a1, a2, a3] to {a1 => nil, a2 => nil, a3 => nil}
        files = Hash[files.map { |f| [f, nil] }].with_indifferent_access
      end
      src_cluster = OODClusters[src_fs.to_sym]
      dest_cluster = OODClusters[dest_fs.to_sym]
      adapter = (src_cluster || dest_cluster)&.file_adapter
      new(action: action, files: files, src_fs: src_cluster || src_fs, dest_fs: dest_cluster || dest_fs,
          tempfile: tempfile, adapter: adapter)
    end
  end

  # total number of bytes, or 100 per file or directory to remove
  def steps
    return @steps if @steps

    @filesizes = {}.with_indifferent_access

    total_size = files.keys.map do |file|
      size = if remove?
               100
             elsif src_fs == RcloneUtil::LOCAL_FS_NAME
               File.size(file)
             else
               adapter.size(file)
             end
      @filesizes[file] = { :size => size, :transferred => 0 }
      size
    rescue StandardError
      @filesizes[file] = { :size => 0, :transferred => 0 }
      0
    end.sum

    @steps = total_size
  end

  def command_str
    ''
  end

  def increment_transferred(amount)
    @transferred = transferred.to_i + amount
  end

  # Updates the total progress with progress of one file since last update
  def update_progress(file, percent_done)
    file_info = filesizes[file]

    current_bytes = (percent_done * file_info[:size]) / 100
    since_last = current_bytes - file_info[:transferred]
    filesizes[file][:transferred] = current_bytes

    increment_transferred(since_last)
    update_percent(transferred)
  end

  def perform
    self.status = OodCore::Job::Status.new(state: :running)
    self.started_at = Time.now.to_i

    raise StandardError, "Unknown action: #{action.inspect}" unless ['mv', 'cp', 'rm'].include?(action)

    # Store info about sizes of files to transfer for tracking progress
    steps

    files.each do |src, dst|
      if tempfile
        # Uploads are Rack tempfiles that only the user can read. The tempfile itself is removed afterwards.
        File.open(src, 'rb') do |io|
          adapter.write(dst, io) do |p|
            update_progress(src, p)
          end
        end
      elsif action == 'mv'
        adapter.move_with_progress(src_fs, dest_fs, src, dst) do |p|
          update_progress(src, p)
        end
      elsif action == 'cp'
        adapter.copy_with_progress(src_fs, dest_fs, src, dst) do |p|
          update_progress(src, p)
        end
      else
        adapter.remove_with_progress(src) do |p|
          update_progress(src, p)
        end
      end
    rescue StandardError => e
      errors.add :base, "Error when transferring #{src}: #{e.message}"
    end
  rescue StandardError => e
    errors.add :base, e.message
  ensure
    self.status = OodCore::Job::Status.new(state: :completed)
    tempfile&.close(true)
  end

  def from
    File.dirname(files.keys.first) if files.keys.first
  end

  def to
    File.dirname(files.values.first) if files.values.first
  end

  def target_dir
    # directory where files are being moved/copied to or removed from
    if action == 'rm'
      Pathname.new(from).cleanpath if from
    elsif to
      Pathname.new(to).cleanpath
    end
  end

  def synchronous?
    false
  end
end
