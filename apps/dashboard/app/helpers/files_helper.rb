# Helper for /files pages.
module FilesHelper
  include ApplicationHelper

  def files_browse_page_title(path)
    site = @user_configuration.dashboard_title
    page = t('dashboard.files_title')
    return t('dashboard.page_title', page: page, site: site) unless path.present?
    dir_segment = path.to_s == '/' ? t('dashboard.root') : path.basename.to_s
    t('dashboard.page_title_with_dir', page: page, site: site, dir: dir_segment)
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
end

