# frozen_string_literal: true

# Controller for the AI Assistant chat functionality
class AssistantController < ApplicationController
  include ActionController::Live
  skip_before_action :verify_authenticity_token, only: [:chat]

  # POST /assistant/chat
  def chat
    return render_error('Assistant not configured') unless assistant_enabled?
    return render_error('Message is required') if params[:message].blank?

    message = params[:message]
    conversation_history = params[:history] || []

    begin
      response = process_chat(message, conversation_history)
      render json: { success: true, response: response }
    rescue StandardError => e
      Rails.logger.error("Assistant error: #{e.message}\n#{e.backtrace.join("\n")}")
      render json: { success: false, error: e.message }, status: :internal_server_error
    end
  end

  # GET /assistant/status
  def status
    render json: {
      enabled: assistant_enabled?,
      features: available_features
    }
  end

  private

  def assistant_enabled?
    ENV['OPENAI_API_KEY'].present? || Configuration.respond_to?(:assistant_api_key) && Configuration.assistant_api_key.present?
  end

  def api_key
    ENV['OPENAI_API_KEY'] || Configuration.assistant_api_key
  end

  def available_features
    {
      jobs: true,
      files: Configuration.can_access_files?,
      batch_connect: true,
      system_status: true
    }
  end

  def process_chat(message, history)
    tools = build_tools
    messages = build_messages(message, history)

    response = call_openai_api(messages, tools)
    
    # Handle tool calls if present
    if response.dig('choices', 0, 'message', 'tool_calls')
      handle_tool_calls(response, messages, tools)
    else
      response.dig('choices', 0, 'message', 'content')
    end
  end

  def build_messages(message, history)
    messages = [{ role: 'system', content: system_prompt }]
    
    # Add conversation history
    history.each do |h|
      messages << { role: h['role'], content: h['content'] }
    end
    
    # Add current message
    messages << { role: 'user', content: message }
    messages
  end

  def system_prompt
    <<~PROMPT
      You are an AI assistant for Open OnDemand, a web-based HPC (High Performance Computing) portal.
      You help users manage their HPC jobs, navigate files, launch interactive applications, and understand system status.

      Current user: #{CurrentUser.name}
      Home directory: #{Dir.home}

      You have access to tools to help users:
      - List and manage jobs (view status, delete jobs)
      - Browse and manage files
      - Get system/cluster status
      - Launch interactive sessions (like Jupyter, RStudio, Desktop)

      Be helpful, concise, and focus on HPC-related tasks. When users ask to perform actions,
      use the available tools. Always confirm before deleting jobs or files.

      Available clusters: #{OODClusters.map(&:id).join(', ')}
    PROMPT
  end

  def build_tools
    [
      {
        type: 'function',
        function: {
          name: 'list_jobs',
          description: 'List all jobs for the current user across clusters',
          parameters: {
            type: 'object',
            properties: {
              cluster: {
                type: 'string',
                description: 'Optional cluster name to filter jobs'
              },
              state: {
                type: 'string',
                enum: %w[all running pending completed],
                description: 'Filter jobs by state'
              }
            }
          }
        }
      },
      {
        type: 'function',
        function: {
          name: 'get_job_details',
          description: 'Get detailed information about a specific job',
          parameters: {
            type: 'object',
            properties: {
              job_id: { type: 'string', description: 'The job ID' },
              cluster: { type: 'string', description: 'The cluster name' }
            },
            required: %w[job_id cluster]
          }
        }
      },
      {
        type: 'function',
        function: {
          name: 'delete_job',
          description: 'Delete/cancel a running or pending job. Always confirm with user first.',
          parameters: {
            type: 'object',
            properties: {
              job_id: { type: 'string', description: 'The job ID to delete' },
              cluster: { type: 'string', description: 'The cluster name' }
            },
            required: %w[job_id cluster]
          }
        }
      },
      {
        type: 'function',
        function: {
          name: 'list_files',
          description: 'List files in a directory',
          parameters: {
            type: 'object',
            properties: {
              path: { type: 'string', description: 'Directory path (default: home directory)' }
            }
          }
        }
      },
      {
        type: 'function',
        function: {
          name: 'get_file_info',
          description: 'Get information about a file or directory',
          parameters: {
            type: 'object',
            properties: {
              path: { type: 'string', description: 'File or directory path' }
            },
            required: ['path']
          }
        }
      },
      {
        type: 'function',
        function: {
          name: 'read_file',
          description: 'Read contents of a text file (first 100 lines)',
          parameters: {
            type: 'object',
            properties: {
              path: { type: 'string', description: 'File path to read' }
            },
            required: ['path']
          }
        }
      },
      {
        type: 'function',
        function: {
          name: 'get_cluster_status',
          description: 'Get status information about HPC clusters',
          parameters: {
            type: 'object',
            properties: {
              cluster: { type: 'string', description: 'Optional specific cluster name' }
            }
          }
        }
      },
      {
        type: 'function',
        function: {
          name: 'list_interactive_sessions',
          description: 'List active interactive sessions (Jupyter, Desktop, etc.)',
          parameters: { type: 'object', properties: {} }
        }
      },
      {
        type: 'function',
        function: {
          name: 'get_available_apps',
          description: 'List available interactive applications that can be launched',
          parameters: { type: 'object', properties: {} }
        }
      },
      {
        type: 'function',
        function: {
          name: 'create_file',
          description: 'Create or overwrite a file with specified content',
          parameters: {
            type: 'object',
            properties: {
              path: { type: 'string', description: 'Full path where to create the file' },
              content: { type: 'string', description: 'Content to write to the file' }
            },
            required: %w[path content]
          }
        }
      },
      {
        type: 'function',
        function: {
          name: 'submit_batch_job',
          description: 'Submit a batch job script to a cluster scheduler',
          parameters: {
            type: 'object',
            properties: {
              cluster: { type: 'string', description: 'Cluster name to submit to' },
              script_path: { type: 'string', description: 'Path to the job script file' },
              script_content: { type: 'string', description: 'Job script content (if creating new script)' },
              working_dir: { type: 'string', description: 'Working directory for the job' }
            },
            required: %w[cluster]
          }
        }
      },
      {
        type: 'function',
        function: {
          name: 'create_and_submit_job',
          description: 'Create a job script and submit it in one step',
          parameters: {
            type: 'object',
            properties: {
              cluster: { type: 'string', description: 'Cluster name' },
              script_name: { type: 'string', description: 'Name for the job script file' },
              script_content: { type: 'string', description: 'Complete job script with headers and commands' },
              working_dir: { type: 'string', description: 'Directory to create script and run job (default: home)' }
            },
            required: %w[cluster script_name script_content]
          }
        }
      }
    ]
  end

  def call_openai_api(messages, tools)
    uri = URI('https://api.openai.com/v1/chat/completions')
    
    body = {
      model: ENV.fetch('OPENAI_MODEL', 'gpt-4o-mini'),
      messages: messages,
      tools: tools,
      tool_choice: 'auto',
      max_tokens: 2000
    }

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 60

    request = Net::HTTP::Post.new(uri)
    request['Authorization'] = "Bearer #{api_key}"
    request['Content-Type'] = 'application/json'
    request.body = body.to_json

    response = http.request(request)
    
    unless response.is_a?(Net::HTTPSuccess)
      error_body = JSON.parse(response.body) rescue { 'error' => response.body }
      raise "OpenAI API error: #{error_body['error']}"
    end

    JSON.parse(response.body)
  end

  def handle_tool_calls(response, messages, tools)
    tool_calls = response.dig('choices', 0, 'message', 'tool_calls')
    assistant_message = response.dig('choices', 0, 'message')
    
    # Add assistant message with tool calls
    messages << assistant_message
    
    # Execute each tool and collect results
    tool_calls.each do |tool_call|
      function_name = tool_call.dig('function', 'name')
      arguments = JSON.parse(tool_call.dig('function', 'arguments') || '{}')
      
      result = execute_tool(function_name, arguments)
      
      messages << {
        role: 'tool',
        tool_call_id: tool_call['id'],
        content: result.to_json
      }
    end
    
    # Get final response with tool results
    final_response = call_openai_api(messages, tools)
    
    # Recursively handle if more tool calls
    if final_response.dig('choices', 0, 'message', 'tool_calls')
      handle_tool_calls(final_response, messages, tools)
    else
      final_response.dig('choices', 0, 'message', 'content')
    end
  end

  def execute_tool(name, arguments)
    case name
    when 'list_jobs'
      tool_list_jobs(arguments)
    when 'get_job_details'
      tool_get_job_details(arguments)
    when 'delete_job'
      tool_delete_job(arguments)
    when 'list_files'
      tool_list_files(arguments)
    when 'get_file_info'
      tool_get_file_info(arguments)
    when 'read_file'
      tool_read_file(arguments)
    when 'get_cluster_status'
      tool_get_cluster_status(arguments)
    when 'list_interactive_sessions'
      tool_list_interactive_sessions
    when 'get_available_apps'
      tool_get_available_apps
    when 'create_file'
      tool_create_file(arguments)
    when 'submit_batch_job'
      tool_submit_batch_job(arguments)
    when 'create_and_submit_job'
      tool_create_and_submit_job(arguments)
    else
      { error: "Unknown tool: #{name}" }
    end
  rescue StandardError => e
    { error: e.message }
  end

  # Tool implementations
  def tool_list_jobs(args)
    jobs = []
    clusters = args['cluster'] ? [OODClusters[args['cluster'].to_sym]].compact : OODClusters.select(&:job_allow?)
    
    clusters.each do |cluster|
      begin
        adapter = cluster.job_adapter
        cluster_jobs = adapter.info_all(attrs: nil).select { |j| j.job_owner == CurrentUser.name }
        
        cluster_jobs.each do |job|
          next if args['state'] && args['state'] != 'all' && !job_state_matches?(job, args['state'])
          
          jobs << {
            id: job.id,
            name: job.job_name,
            cluster: cluster.id.to_s,
            state: job.status.state.to_s,
            queue: job.queue_name,
            walltime: job.wallclock_time,
            nodes: job.allocated_nodes&.size
          }
        end
      rescue StandardError => e
        Rails.logger.warn("Failed to get jobs from #{cluster.id}: #{e.message}")
      end
    end
    
    { jobs: jobs, count: jobs.size }
  end

  def job_state_matches?(job, state)
    case state
    when 'running'
      job.status.running?
    when 'pending', 'queued'
      job.status.queued?
    when 'completed'
      job.status.completed?
    else
      true
    end
  end

  def tool_get_job_details(args)
    cluster = OODClusters[args['cluster'].to_sym]
    return { error: "Cluster not found: #{args['cluster']}" } unless cluster
    
    job = cluster.job_adapter.info(args['job_id'])
    
    {
      id: job.id,
      name: job.job_name,
      owner: job.job_owner,
      state: job.status.state.to_s,
      queue: job.queue_name,
      walltime_used: job.wallclock_time,
      walltime_limit: job.wallclock_limit,
      submit_time: job.submission_time&.to_s,
      start_time: job.dispatch_time&.to_s,
      nodes: job.allocated_nodes&.map(&:name),
      native_info: job.native&.slice('Resource_List', 'resources_used', 'Exit_status')
    }
  rescue StandardError => e
    { error: e.message }
  end

  def tool_delete_job(args)
    cluster = OODClusters[args['cluster'].to_sym]
    return { error: "Cluster not found: #{args['cluster']}" } unless cluster
    
    cluster.job_adapter.delete(args['job_id'])
    { success: true, message: "Job #{args['job_id']} has been deleted" }
  rescue StandardError => e
    { error: e.message }
  end

  def tool_list_files(args)
    path = args['path'] || Dir.home
    path_obj = PosixFile.new(path)
    
    return { error: 'Path does not exist' } unless path_obj.exist?
    return { error: 'Path is not a directory' } unless path_obj.directory?
    
    files = path_obj.ls.first(50).map do |f|
      {
        name: f[:name],
        type: f[:directory] ? 'directory' : 'file',
        size: f[:size],
        modified: f[:date]&.to_s
      }
    end
    
    { path: path, files: files, truncated: path_obj.ls.size > 50 }
  rescue StandardError => e
    { error: e.message }
  end

  def tool_get_file_info(args)
    path_obj = PosixFile.new(args['path'])
    
    return { error: 'Path does not exist' } unless path_obj.exist?
    
    stat = File.stat(args['path'])
    {
      path: args['path'],
      type: path_obj.directory? ? 'directory' : 'file',
      size: stat.size,
      permissions: stat.mode.to_s(8),
      owner: stat.uid,
      modified: stat.mtime.to_s,
      readable: File.readable?(args['path']),
      writable: File.writable?(args['path'])
    }
  rescue StandardError => e
    { error: e.message }
  end

  def tool_read_file(args)
    path = args['path']
    
    return { error: 'File does not exist' } unless File.exist?(path)
    return { error: 'Cannot read directories' } if File.directory?(path)
    return { error: 'File not readable' } unless File.readable?(path)
    
    # Check if file is likely binary
    if File.size(path) > 1_000_000
      return { error: 'File too large (>1MB)', size: File.size(path) }
    end
    
    content = File.read(path, 100_000) # Read first 100KB
    lines = content.lines.first(100)
    
    {
      path: path,
      content: lines.join,
      lines_shown: lines.size,
      truncated: content.lines.size > 100 || File.size(path) > 100_000
    }
  rescue StandardError => e
    { error: e.message }
  end

  def tool_get_cluster_status(args)
    clusters = args['cluster'] ? [OODClusters[args['cluster'].to_sym]].compact : OODClusters.to_a
    
    statuses = clusters.map do |cluster|
      status = {
        id: cluster.id.to_s,
        name: cluster.metadata.title || cluster.id.to_s,
        login_host: cluster.login.host
      }
      
      # Try to get job adapter info
      begin
        if cluster.job_allow?
          adapter = cluster.job_adapter
          all_jobs = adapter.info_all(attrs: nil)
          status[:total_jobs] = all_jobs.size
          status[:running_jobs] = all_jobs.count { |j| j.status.running? }
          status[:queued_jobs] = all_jobs.count { |j| j.status.queued? }
        end
      rescue StandardError => e
        status[:error] = e.message
      end
      
      status
    end
    
    { clusters: statuses }
  end

  def tool_list_interactive_sessions
    sessions = BatchConnect::Session.all.map do |session|
      {
        id: session.id,
        app: session.title,
        status: session.status.to_s,
        cluster: session.cluster_id,
        created_at: session.created_at&.to_s,
        time_remaining: session.status.running? ? "#{session.time_remaining / 60} minutes" : nil,
        connect_url: session.status.running? ? session.connect.url : nil
      }
    end
    
    { sessions: sessions, count: sessions.size }
  rescue StandardError => e
    { error: e.message }
  end

  def tool_get_available_apps
    apps = BatchConnect::App.all.select(&:valid?).map do |app|
      {
        token: app.token,
        title: app.title,
        description: app.description,
        cluster: app.cluster&.id&.to_s
      }
    end
    
    { apps: apps }
  rescue StandardError => e
    { error: e.message }
  end

  def tool_create_file(arguments)
    path = arguments['path']
    content = arguments['content']
    
    return { error: 'Path is required' } if path.blank?
    return { error: 'Content is required' } if content.blank?
    
    # Expand path and ensure it's absolute
    expanded_path = Pathname.new(path).expand_path
    
    # Security: ensure path is within user's accessible directories
    home_dir = Pathname.new(Dir.home)
    unless expanded_path.to_s.start_with?(home_dir.to_s)
      return { error: 'Access denied: can only write to home directory' }
    end
    
    # Create parent directories if needed
    FileUtils.mkdir_p(expanded_path.dirname)
    
    # Write the file
    File.write(expanded_path, content)
    
    {
      success: true,
      path: expanded_path.to_s,
      size: File.size(expanded_path),
      message: "File created successfully at #{expanded_path}"
    }
  rescue StandardError => e
    { error: e.message }
  end

  def tool_submit_batch_job(arguments)
    cluster_id = arguments['cluster']
    script_path = arguments['script_path']
    working_dir = arguments['working_dir'] || Dir.home
    
    return { error: 'Cluster is required' } if cluster_id.blank?
    return { error: 'Script path is required' } if script_path.blank?
    
    cluster = OODClusters[cluster_id.to_sym]
    return { error: "Cluster '#{cluster_id}' not found" } unless cluster
    return { error: "Cluster '#{cluster_id}' has no job adapter" } unless cluster.job_config
    
    # Expand paths
    script_path = Pathname.new(script_path).expand_path.to_s
    working_dir = Pathname.new(working_dir).expand_path.to_s
    
    # Submit the job
    adapter = cluster.job_adapter
    job_id = adapter.submit(
      script: OodCore::Job::Script.new(
        script: File.read(script_path),
        workdir: working_dir
      )
    )
    
    {
      success: true,
      job_id: job_id.to_s,
      cluster: cluster_id,
      script_path: script_path,
      message: "Job #{job_id} submitted successfully to #{cluster_id}"
    }
  rescue StandardError => e
    { error: e.message }
  end

  def tool_create_and_submit_job(arguments)
    cluster_id = arguments['cluster']
    script_name = arguments['script_name']
    script_content = arguments['script_content']
    working_dir = arguments['working_dir'] || Dir.home
    
    return { error: 'Cluster is required' } if cluster_id.blank?
    return { error: 'Script name is required' } if script_name.blank?
    return { error: 'Script content is required' } if script_content.blank?
    
    cluster = OODClusters[cluster_id.to_sym]
    return { error: "Cluster '#{cluster_id}' not found" } unless cluster
    return { error: "Cluster '#{cluster_id}' has no job adapter" } unless cluster.job_config
    
    # Expand working directory
    working_dir = Pathname.new(working_dir).expand_path
    FileUtils.mkdir_p(working_dir)
    
    # Create script file
    script_path = working_dir.join(script_name)
    File.write(script_path, script_content)
    File.chmod(0755, script_path)
    
    # Submit the job
    adapter = cluster.job_adapter
    job_id = adapter.submit(
      script: OodCore::Job::Script.new(
        script: script_content,
        workdir: working_dir.to_s
      )
    )
    
    {
      success: true,
      job_id: job_id.to_s,
      cluster: cluster_id,
      script_path: script_path.to_s,
      working_dir: working_dir.to_s,
      message: "Job script created at #{script_path} and submitted as job #{job_id} to #{cluster_id}"
    }
  rescue StandardError => e
    { error: e.message }
  end

  def render_error(message)
    render json: { success: false, error: message }, status: :bad_request
  end
end
