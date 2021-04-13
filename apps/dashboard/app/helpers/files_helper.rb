module FilesHelper
  #FIXME: handle by Transfer#all model method
  def sort_by_created_at(transfers)
    transfers.sort_by { |t| - t.created_at }
  end

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
