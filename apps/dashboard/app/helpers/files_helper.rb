# Helper for /files pages.
module FilesHelper
  include ApplicationHelper
  
  def files_browse_page_title(path)
    prefix = "#{t('dashboard.files_title')} - #{@user_configuration.dashboard_title}"
    return prefix if path.blank?

    dir_segment = (path.to_s == '/') ? 'Root' : path.basename.to_s
    "#{prefix} - #{dir_segment}"
  end

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

  def files_editor_api_url(path:, filesystem:)
    api_url = OodAppkit.files.api(path: '/', fs: filesystem).to_s
    base = api_url.chomp('/')
    "#{controller.relative_url_root}#{base.match(%r{(/files/api/v1/fs).*})[1]}#{url_encode_path(path.to_s)}"
  end
end
