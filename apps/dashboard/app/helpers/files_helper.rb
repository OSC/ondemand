module FilesHelper
  def path_segment_with_slash(segment, counter, total)
    # TODO: ucomment if we decide to omit trailing slash on current directory
    # if counter == 0 || counter == total - 1
    if counter == 0
      segment
    else
      segment + " /"
    end
  end
end
