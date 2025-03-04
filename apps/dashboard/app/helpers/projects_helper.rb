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

  # This will always create a local shared lookup file
  # It will save directory path of shared OOD projects in this file after brute forcing all possible path
  def save_shared_dir
    shared_path = []
    Configuration.shared_projects_root.each do |path|
      CurrentUser.group_names.each do |group|
        dir_path = path.join(group)
        # {shared_projects_path}/<UNIX group ID>/<project>/.ondemand
        if dir_path.exist? && dir_path.directory? 
          Dir.each_child(dir_path) do |child|
            if File.directory?(File.join(dir_path, child, '.ondemand'))
              shared_path << File.join(dir_path, child)
            end
          end
        end

      end
    end

    # TODO: First brute force all path and do `ls -l` to check if it is part of user group
    # save to local varible shared_path
    # Next check if any child in shared path is ood project and save it to ood_shared_projects
    # finally save this local varible below to lookup file
    
    # Cache the shared path, so these are visible accross instances of project controller
    dataroot = OodAppkit.dataroot.join('projects')
    shared_cache = Pathname("#{dataroot}/.shared_lookup")
    File.open(shared_cache, "w") do |file|
      shared_path.each do |path|
        file.puts path
      end
    end
  end
end
