module FilesHelper
  #FIXME: handle by Transfer#all model method
  def sort_by_created_at(transfers)
    transfers.sort_by { |t| - t.created_at }
  end
end
