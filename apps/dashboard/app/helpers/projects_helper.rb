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

  # TODO: Use it to populate drop down selection of shared directory in import project form
  def cached_shared_dir
    Rails.cache.fetch('cached_shared_dir', expires_in: 1.hour) do
      shared_dir_list
    end
  end
  
  private
  def shared_dir_list
    shared_path = []
    Configuration.shared_projects_root.each do |dir_path|
      next unless File.readable?(dir_path)
      Dir.each_child(dir_path) do |child|
        child_dir = File.join(dir_path, child)
        gid = File.stat(child_dir).gid
        name = Etc.getgrgid(gid).name rescue nil
        next unless CurrentUser.group_names.include?(name)
        shared_path << child_dir
      end
    end

    return shared_path
  end
end
