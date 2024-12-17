# frozen_string_literal: true

# Helpers for the projects page
module ProjectsHelper
  include ApplicationHelper
  
  def render_readme(readme_location)
    file_content = File.read(readme_location)
    if File.extname(readme_location) == '.md'
      markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
      markdown_html = markdown.render(file_content).html_safe
      sanitize(markdown_html)
    elsif File.extname(readme_location) == '.txt'
      # simple_format sanitizes its output
      simple_format(file_content)
    end
  end

  def job_details_buttons(status, job, project)
    locals = { project_id: project.id, id: job.id, cluster: job.cluster }
    button_partial = button_category(status)
    render(partial: "projects/buttons/#{button_category(status)}_buttons", locals: locals) unless button_partial.nil?
  end

  def button_category(status)
    case status
    when 'queued_held'
      'held'
    when 'suspended'
      'held'
    else
      status
    end
  end

  def files_button(path)
    link_to(
      ".../projects#{path.to_s.split('projects')[1]}",
      files_path(fs: 'fs', filepath: path),
      target: '_top',
      class: 'link-light'
      ).html_safe
  end

  def column_head_link(column, sort_by, path, project_id)
    link_to(
      header_text(column, sort_by),
      target_path(column, path, project_id),
      title: "Show #{path.basename} directory", 
      class: classes(column, sort_by),
      data: { turbo_frame: 'project_directory' }
    )
  end

  def header_text(column, sort_by)
    "#{t("dashboard.#{column.to_s}")} #{fa_icon(column.to_s == sort_by.to_s ? 'sort-down' : 'sort', classes: 'fa-md')}".html_safe
  end

  def target_path(column, path, project_id)
    project_directory_path(
      { project_id: project_id,
        dir_path: path.to_s,
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
