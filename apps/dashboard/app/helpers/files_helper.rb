# Helper for /files pages.
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
end
