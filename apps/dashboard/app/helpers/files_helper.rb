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

  def files_button(path)
    link_to(
      frame_path(path),
      files_path(fs: 'fs', filepath: path),
      target: '_top',
      class: 'link-light'
      ).html_safe
  end

  def frame_path(path)
    return ".../projects#{path.to_s.split('projects')[1]}" if path.to_s.include?('projects')
    path_components = path.to_s.split('/')
    starting_index = path_components.length < 5 ? 0 : path_components.length - 5
    return ".../#{path_components[starting_index..-1].join('/')}"
  end

  def column_head_link(column, sort_by, path)
    link_to(
      header_text(column, sort_by),
      target_path(column, path),
      title: "Show #{path.basename} directory", 
      class: classes(column, sort_by),
      data: { turbo_frame: 'project_directory' }
    )
  end

  def header_text(column, sort_by)
    "#{t("dashboard.#{column.to_s}")} #{fa_icon(column.to_s == sort_by.to_s ? 'sort-down' : 'sort', classes: 'fa-md')}".html_safe
  end

  def target_path(column, path)
    directory_frame_path(
      { path: path.to_s,
        sort_by: column
      }
    )
  end

  def classes(column, sort_by)
    classes = ['btn', 'btn-xs', 'btn-hover']
    classes << (column.to_s == sort_by.to_s ? ['btn-primary'] : ['btn-outline-primary'])
    classes.join(' ')
  end
end
