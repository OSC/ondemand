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

  def bottom_buttons(status)
    return unless status == 'completed'

    locals = { project_id: @project.id, id: job.id, cluster: job.cluster }
    render(partial: 'projects/buttons/bottom_buttons', locals: locals)
  end

  def top_buttons(status)
    return if status == 'completed'

    render(partial: "projects/buttons/#{button_category(status)}_buttons")
  end

  def button_category(status)
    status
  end
end
