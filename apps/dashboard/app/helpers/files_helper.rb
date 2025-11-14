# Helper for /files pages.
module FilesHelper
  include ApplicationHelper
  
  def path_segment_with_slash(filesystem, segment, counter, total)
    # TODO: add check for counter == total - 1 if we decide to omit trailing slash on current directory
    if counter == 0
      if filesystem == 'fs'
        segment
      else
        "#{filesystem}: #{segment}"
      end
    else
      segment + " /"
    end
  end

  def files_button(path, text = "Open in files app")
    link_to(
      text,
      files_path(fs: 'fs', filepath: path),
      target: '_top',
      class: 'btn btn-primary btn-sm files-button'
      )
  end

  def frame_path(path)
    path.to_s
  end

  def project_dir_files_url(path)
    if use_edit_url?(path)
      edit_files_path(path)
    else  
      files_path(path)
    end
  end

  private

  def use_edit_url?(string_path)
    path = Pathname.new(string_path)
    return false if ['.log','.out'].include?(path.extname)
    return false unless File.writable?(path)
    if ['.yml','.json'].include?(path.extname)
      path.ascend do |parent|
        return false if parent.basename.to_s == '.ondemand'
      end
    end
    true
  end  
end

