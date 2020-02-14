class WorkflowFile
  attr_reader :path, :staged_dir

  def initialize(path, staged_dir)
    @path = path
    @staged_dir = staged_dir
  end

  # Get an array of files of a directory meeting the criteria for job scripts in alphabetical order
  #
  # Filter the files by file size, extension and content
  def suggested_script?
    @suggested_script ||= (valid_size? && ( has_suggested_extensions? || starts_with_shebang_line? || has_resource_manager_directive?))
  end
 
  # Return true if the file meets the basic requirements to be a job script
  def valid_script?
    @valid_script ||= valid_size?
  end
  
  # Return true if file name extention is in the recommended extension list
  def has_suggested_extensions?
    suggested_job_script_file_extensions = [".sh", ".job", ".slurm", ".batch", ".qsub", ".sbatch", ".srun", ".bsub"]
    suggested_job_script_file_extensions.include? File.extname(path)
  end
  
  # Return true if file starts with a shebang line
  def starts_with_shebang_line?
    begin
      (File.open(path) { |f| f.read(2) }) == "#!"
    rescue
      false
    end
  end

  # Return true if first 1000 bytes of file contain '#PBS' or '#SBATCH" or '#BSUB' or '#$'
  def has_resource_manager_directive?
    begin
      contents = File.open(path) { |f| f.read(1000) }
      contents && (contents.include?("#PBS") || contents.include?("#SBATCH") || contents.include?('#BSUB') || contents.include?('#$'))
    rescue
      false
    end
  end

  # Return true if file size is smaller than 65KB
  def valid_size?
    File.size(path).to_f/1024 <= 65
  end  
  
  # Return relative file path uses staged_dir as base
  def relative_path
    path.gsub(staged_dir, "").sub!(/^\//, '')
  end
end
