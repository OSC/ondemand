# frozen_string_literal: true

# ClusterFile is a class representing a file on a file system belonging to a cluster.
class ClusterFile
  attr_reader :path, :cluster, :file_adapter

  delegate :basename, :descend, :parent, :join, :to_s, to: :path

  def initialize(path, cluster)
    @path = Pathname.new(path)
    @cluster = OODClusters[cluster]
    raise StandardError, "No such cluster for ClusterFile: #{cluster}" unless @cluster

    @file_adapter = @cluster.file_adapter
  end

  def remote_type
    'cluster'
  end

  def raise_if_cant_access_directory_contents; end

  def directory?
    file_adapter.directory?(path)
  end

  def ls
    file_adapter.ls(path).map do |stats|
      {
        id:           File.join(path, stats[:name]),
        dev:          0,
        downloadable: true
      }.merge(stats)
    end.select do |stats|
      valid_encoding = stats[:name].to_s.valid_encoding?
      Rails.logger.warn("Not showing file '#{stats[:name]}' because it is not a UTF-8 filename.") unless valid_encoding
      valid_encoding
    end.sort_by { |p| p[:directory] ? 0 : 1 }
  end

  def can_download_as_zip?(timeout: Configuration.download_dir_timeout_seconds,
                           download_directory_size_limit: Configuration.download_dir_max)
    if file_adapter.directory_size(path, timeout: timeout) > download_directory_size_limit
      [false, I18n.t('dashboard.files_directory_too_large', download_directory_size_limit: download_directory_size_limit)]
    else
      [true, nil]
    end
  rescue Timeout::Error
    [false, I18n.t('dashboard.files_directory_size_calculation_timeout')]
  rescue StandardError => e
    [false, I18n.t('dashboard.files_directory_size_error', error: e.message)]
  end

  def can_download_file?
    download_file_size_limit = Configuration.download_file_max
    if size > download_file_size_limit
      [false, I18n.t('dashboard.files_file_too_large', download_file_size_limit: download_file_size_limit)]
    elsif !file_adapter.readable?(path)
      [false, I18n.t('dashboard.files_not_readable', path: path.to_s)]
    else
      [true, nil]
    end
  end

  FileToZip = Struct.new(:path, :relative_path, :realpath)

  def files_to_zip
    file_adapter.ls_recursive(path).select do |filepath|
      valid_encoding = filepath.valid_encoding?
      Rails.logger.warn("Not zipping file '#{filepath}' because it is not a UTF-8 filename.") unless valid_encoding
      valid_encoding
    end.map do |filepath|
      FileToZip.new(filepath.to_s, Pathname.new(filepath).relative_path_from(path).to_s, filepath.to_s)
    end.reject do |file|
      file.relative_path == '.'
    end
  end

  def download_as_zip(stream)
    ZipKit::Streamer.open(stream) do |zip|
      files_to_zip.each do |file|
        # Errors are rescued outside of the block, so that ZipKit rolls back the partially written file.
        zip.write_deflated_file(file.relative_path.to_s) do |zip_file|
          file_adapter.read(file.path) do |data|
            zip_file.write(data)
          end
        end
      rescue StandardError => e
        Rails.logger.warn("error writing file #{file.path} to zip: #{e.message}")
      end
    end
  end

  def editable?
    file_adapter.editable?(path)
  end

  def read(&block)
    file_adapter.read(path, &block)
  end

  def size
    file_adapter.size(path)
  end

  def mime_type
    type = file_adapter.mime_type(path)

    # Empty files are "inode/x-empty", but are treated as text, like in PosixFile#mime_type.
    type == 'inode/x-empty' ? 'text/plain' : type
  end

  def to_str
    to_s
  end
end
