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

  def project_dir_files_url(path, editable_exts)
    editable_exts ||= Project.editable_extensions

    if use_edit_url?(path, editable_exts)
      edit_files_path(path)
    else
      files_path(path)
    end
  end

  private

  def use_edit_url?(string_path, editable_extensions)
    path = Pathname.new(string_path)
    return false unless File.writable?(path)
    return true if editable_extensions.include?(path.extname)
    return true if path.basename.to_s == '.editable_extensions.yml'

    false
  end  
end

