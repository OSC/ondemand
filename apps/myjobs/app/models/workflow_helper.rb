class WorkflowHelper
  # Get an array of all the files of a directory
  #
  # Find.find returns an enumerator - the first path is always the initial directory
  # so we return the array with the first item omitted
  def folder_contents(staged_dir)
    File.directory?(staged_dir) ? Find.find(staged_dir).to_a[1..-1] : []
  end

  # Get an array of files of a directory meeting the criteria for job scripts in alphabetical order
  #
  # Filter the files by file size, extension and content
  def get_suggested_script_files(staged_dir)
     (folder_contents(staged_dir).find_all { |file| 
       (File.file?(file) && has_valid_size(file)) && (has_suggested_extensions(file) || starts_with_shebang_line(file) || has_specific_command(file))
     }).sort
  end

  # Get an array of files of a directory meeting only the file size requirement in alphabetical order
  def other_valid_job_scripts(staged_dir)
     (folder_contents(staged_dir).find_all { |file| 
       File.file?(file) && has_valid_size(file)
     }).sort - get_suggested_script_files(staged_dir)
  end
  
  # Return true if file name extention is in the recommended extension list
  def has_suggested_extensions(file)
    suggested_job_script_file_extensions = [".sh", ".job", ".slurm", ".batch", ".qsub", ".sbatch", ".srun", ".bsub"]
    suggested_job_script_file_extensions.include? File.extname(file)
  end
  
  # Return true if file starts with a shebang line
  def starts_with_shebang_line(file)
      (File.open(file) { |f| f.read(2) }) == "#!"
  end

  # Return true if first 1000 bytes of file contain '#PBS' or '#SBATCH"
  def has_specific_command(file)
      contents = File.open(file) { |f| f.read(1000) }
      contents.include?("#PBS") || contents.include?("#SBATCH")
  end

  # Return true if file size is smaller than 65KB
  def has_valid_size(file)
      File.size(file).to_f/1024 <= 65
  end  
  
  # Return relative file path uses staged_dir as base
  def parse_relative_path(file_path, staged_dir)
    file_path.gsub(staged_dir, "").sub!(/^\//, '')
  end
end
