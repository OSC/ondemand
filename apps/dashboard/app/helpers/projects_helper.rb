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

  def native_message(native)
    state = native.dig(:state)
    msg = "Current job state is #{state}"
    
    reason = native.dig(:reason)
    if reason != "None"
      msg += " because of #{reason}"
    end
    
    dependency = native.dig(:dependency)
    if dependency != "(null)" and state != "CANCELLED"
      dependency = truncate(dependency.gsub("afterok:", " "), length: 50)
      msg += ". Job depends on job-id#{dependency}"
    end

    # Special case: Showing dependency of cancelled job will confuse users
    if state=="CANCELLED" and reason=="Dependency"
      msg = "Current job state is #{state}"
    end
    
    msg += "."
    return msg
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
end
