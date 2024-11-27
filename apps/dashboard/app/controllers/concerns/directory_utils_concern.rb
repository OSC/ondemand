module DirectoryUtilsConcern
  # Constants for sorting
  ASCENDING = true
  DESCENDING = false
  # Constants for grouping
  DIRECTORIES = true
  FILES = false
  DEFAULT_SORTING_PARAMS = { col: 'name', direction: ASCENDING, grouped?: true }

  extend ActiveSupport::Concern

  def normalized_path(path)
    Pathname.new("/#{path.to_s.chomp('/').delete_prefix('/')}")
  end

  def parse_path(path = nil, filesystem = nil)
    normal_path = normalized_path(path || resolved_path)
    filesystem ||= resolved_fs
    if filesystem == 'fs'
      @path = PosixFile.new(normal_path)
      @filesystem = 'fs'
    elsif ::Configuration.remote_files_enabled? && filesystem != 'fs'
      @path = RemoteFile.new(normal_path, filesystem)
      @filesystem = filesystem
    else
      @path = PosixFile.new(normal_path)
      @filesystem = filesystem
      raise StandardError, I18n.t('dashboard.files_remote_disabled')
    end
  end

  def validate_path!
    if posix_file?
      AllowlistPolicy.default.validate!(@path)
    elsif @path.remote_type.nil?
      raise StandardError, "Remote #{@path.remote} does not exist"
    elsif ::Configuration.allowlist_paths.present? && (@path.remote_type == 'local' || @path.remote_type == 'alias')
      # local and alias remotes would allow bypassing the AllowListPolicy
      # TODO: Attempt to evaluate the path of them and validate?
      raise StandardError, "Remotes of type #{@path.remote_type} are not allowed due to ALLOWLIST_PATH"
    end
  end

  def set_sorting_params(parameters)
    @sorting_params = {
      col: parameters[:col],
      direction: parameters[:direction],
      grouped?: parameters[:grouped?]
    }
  end

  def set_files
    @files = @path.ls
    @files = sort_by_column(@files, @sorting_params[:col], @sorting_params[:direction])
    @files = group_by_type(@files) if @sorting_params[:grouped?]
  end

  def group_by_type(files)
    directories = files.select { |file| file[:directory] } + files.select { |file| !file[:directory] }
  end

  def sort_by_column(files, column, direction)
    col = column.to_sym
    sorted_files = files.sort_by do |file|
      if col == :size
        file[col].to_i
      else
        file[col].to_s.downcase
      end
    end
    return sorted_files if direction == ASCENDING
    return sorted_files.reverse
  end

  def posix_file?
    @path.is_a?(PosixFile)
  end
  
  def resolved_path
    raise NoMethodError, "Must implement resolved_path in #{self.class.to_s} to use Pathable concern"
  end

  def resolved_fs
    raise NoMethodError, "Must implement resolved_fs in #{self.class.to_s} to use Pathable concern"
  end
end
