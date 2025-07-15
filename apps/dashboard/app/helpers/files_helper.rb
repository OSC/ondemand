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
end

