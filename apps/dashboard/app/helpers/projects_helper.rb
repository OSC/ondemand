# frozen_string_literal: true

# Helpers for the projects page
module ProjectsHelper
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

  def files_button
    link_to(
      ".../projects#{@path.to_s.split('projects')[1]}",
      files_path(fs: 'fs', filepath: @path),
      target: '_top',
      class: 'link-light'
      ).html_safe
  end

  # <a id="new-dir-btn" class="btn btn-outline-dark" href="<%= files_path(fs: 'fs', filepath: path ) %>">
  # <i class="fas fa-folder-open" aria-hidden="true"></i>
  # <%=  "Go To Files: .../projects#{@path.to_s.split('projects')[1]}" %>
  # <%- if Configuration.project_size_enabled -%>
  #   <span data-bs-toggle="project" data-url="<%= project_path(@project.id) %>"></span>
  # <%- end -%>
  # </a>

  def project_size

  end

  # DRAFT: Remove if not needed
  # def group_by_type_link
  #   group_link_text = "#{@sorting_params[:grouped?] ? 'Ungroup' : 'Group'}"
  #   group_link_title = @sorting_params[:grouped?] ? 'Ungroup results by type' : 'Group results by type'
  #   link_to(
  #     "Group",
  #     target_path(@sorting_params[:col], !@sorting_params[:grouped?]),
  #     title: "Group results by type",
  #     class: "btn btn-1 btn-primary btn-hover btn-sm align-self-end ml-auto",
  #     data: data_attributes
  #   )
  # end

  def column_head_link(column, sorting_params)
    link_to(
      link_text(column, sorting_params),
      target_path(column, sorting_params),
      title: tool_tip, 
      class: "text-dark",
      data: data_attributes
    )
  end

  def direction(column, sorting_params)
    return !sorting_params[:direction] if column.to_s == sorting_params[:col].to_s
    ascending
  end

  def link_text(column, sorting_params)
    col_title = t("dashboard.#{column.to_s}")
    if column.to_s == sorting_params[:col]
      "#{col_title} #{ fa_icon(direction(column, sorting_params) == ascending ? 'sort-up' : 'sort-down', classes: 'fa-md') }".html_safe
    else
      "#{col_title} #{ fa_icon('sort', classes: 'fa-md') }".html_safe
    end
  end

  def target_path(column, sorting_params)
    project_directory_path(
      { project_id: @project.id,
        dir_path: @path.to_s,
        sorting_params: { col: column,
                          direction: direction(column, sorting_params),
                          grouped?: sorting_params[:grouped]
                        }
      }
    )
  end

  def tool_tip
    "Show #{@path.basename} directory"
  end

  def data_attributes
    { turbo_frame: 'project_directory' }
  end

  def ascending
    DirectoryUtilsConcern::ASCENDING
  end

  def descending
    DirectoryUtilsConcern::DESCENDING
  end
end
