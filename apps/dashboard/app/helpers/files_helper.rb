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

  def editor_url(filesystem, path)
    base = ENV['OOD_EDITOR_URL']   || '/pun/sys/dashboard/files'
    OodAppkit::Urls::Editor.new(edit_url: "#{base}/edit/#{filesystem}" ).edit(path: path).to_s
  end

  def file_api_url(filesystem, path)
    base = ENV['OOD_FILES_URL']   || '/pun/sys/dashboard/files'
    OodAppkit::Urls::Files.new(api_url: "#{base}/#{filesystem}" ).api(path: path).to_s
  end
end
