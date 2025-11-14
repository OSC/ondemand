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

  def possible_user_groups(project)
    user_groups = Process.groups.map{|id| Etc.getgrgid(id).name}
    # accept path arg directly for debugging
    root_dir = project.is_a?(Pathname) ? project : project.project_dataroot

    ancestors = []
    root_dir.ascend do |parent|
      ancestors.push(parent) unless parent == root_dir
    end

    candidates = user_groups.dup

    # check that ancestors are not restricted to specific groups
    ancestors.each do |a|
      st = a.stat
      mode = st.mode & 0o777
      other_x = (mode & 0o001) != 0
      group_x = (mode & 0o010) != 0

      next if other_x

      if group_x
        gname = Etc.getgrgid(st.gid).name rescue nil
        return [] unless gname
        # if they are, restrict candidates to that group
        candidates &= [gname]
      else
        return []
      end
      break if candidates.empty?
    end

    candidates.sort.uniq
  end
end
