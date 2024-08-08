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

  # Organizes job information in a manner that is easily displayed
  def readable_job_data(job)
    account_info = {}
    status_info = {}
    job_info = {}
    job.to_h.each do |key, value|
      unless value.nil?
        case key
        when 'job_name'
          account_info['Job Name'] = value
        when 'job_owner'
          account_info['Job Owner'] = value
        when 'accounting_id'
          account_info['Account'] = value
        when 'submission_time'
          status_info['Submission Time'] = value
        when 'dispatch_time'
          status_info['Dispatch Time'] = value
        when 'wallclock_time'
          status_info['Time Used'] = value
        when 'wallclock_limit'
          status_info['Time Remaining'] = value - job.wallclock_time
        when 'cluster'
          job_info['Cluster'] = value
        when 'queue_name'
          job_info['Queue Name'] = value
        when 'procs'
          job_info['CPUs'] = value
        when 'allocated_nodes'
          job_info['Allocated Nodes'] = value unless value.empty?
        when 'gpus'
          job_info['GPUs'] = value
        when 'nodes'
          job_info['Nodes'] = value
        when 'min_memory'
          job_info['Minimum Memory'] = value
        when 'tasks'
          job_info['Tasks'] = value unless value.empty?
        end
      end
    end

    {
      'Account Information': account_info,
      'Job Status': status_info,
      'Job Information': job_info
    }
  end
end