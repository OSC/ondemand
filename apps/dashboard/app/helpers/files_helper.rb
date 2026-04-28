# Helper for /files pages.

require 'uri'

module FilesHelper
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

  def url_encode_path(path)
    path.to_s.split('/').map { |seg| ERB::Util.url_encode(seg.to_s) }.join('/')
  end

  def url_encode_url_path(url)
    path, query = url.to_s.split('?', 2)
    encoded = url_encode_path(path)
    query ? "#{encoded}?#{query}" : encoded
  end
end
