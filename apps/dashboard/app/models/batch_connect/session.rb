module BatchConnect
  # An active batch connect session. Once a batch connect app launches, we use
  # this class to hold it's runtime attributes.
  class Session
    include ActiveModel::Model
    include ActiveModel::Serializers::JSON
    include SanitizedEnv

    # This class describes the object that is bound to the ERB template file
    # when it is rendered
    TemplateBinding = Struct.new(:session, :context) do
      # Get the binding for this object
      # @return [Binding] this object's binding
      def get_binding
        binding()
      end
    end

    # Unique identifier that describes this session
    # @return [String] session id
    attr_accessor :id

    # Cluster used from the global cluster config
    # @return [String] cluster id
    attr_accessor :cluster_id

    # Job id for the given cluster's resource manager
    # @return [String] job id
    attr_accessor :job_id

    # When this session was created at as a unix timestamp
    # @return [Integer] created at
    attr_accessor :created_at

    # When this session finished, as a unix timestamp
    # @return [Integer] completed at
    attr_accessor :completed_at

    # Token describing app and sub app
    # @return [String] app token
    attr_accessor :token

    # The title for the session
    # @return [String] session title
    attr_accessor :title

    # Batch connect script type
    # @return [String] script type
    attr_accessor :script_type

    # Cached value to indicate the job is completed
    # We call this cache_completed, not completed to avoid the risk of confusing
    # completed with completed?
    #
    # @return [Boolean] true if job is completed
    attr_accessor :cache_completed

    # Error message about failing to parse info view ERB template.
    # @return [String] error message
    attr_reader :render_info_view_error_message
    
    # Error message about failing to parse completed view ERB template.
    # @return [String] error message
    attr_reader :render_completed_view_error_message

    # Return parsed markdown from info.{md, html}.erb
    # @return [String, nil] return HTML if no error while parsing, else return nil
    def render_info_view
      @render_info_view ||= OodAppkit.markdown.render(ERB.new(self.app.session_info_view, trim_mode: "-").result(binding)).html_safe if self.app.session_info_view
    rescue => e
      @render_info_view_error_message = "Error when rendering info view: #{e.class} - #{e.message}"
      Rails.logger.error(@render_info_view_error_message)
      nil
    end

    # Return parsed markdown from completed.{md, html}.erb
    # @return [String, nil] return HTML if no error while parsing, else return nil
    def render_completed_view
      @render_completed_view ||= OodAppkit.markdown.render(ERB.new(self.app.session_completed_view, trim_mode: '-').result(binding)).html_safe if self.app.session_completed_view
    rescue => e
      @render_completed_view_error_message = "Error when rendering completed view: #{e.class} - #{e.message}"
      Rails.logger.error(@render_completed_view_error_message)
      nil
    end
    
    # Return the Batch Connect app from the session token
    # @return [BatchConnect::App]
    def app
      @app ||= BatchConnect::App.from_token(self.token)
    end

    # Attributes used for serialization
    # @return [Hash] attributes to be serialized
    def attributes
      %w(id cluster_id job_id created_at token title script_type cache_completed completed_at).map do |attribute|
        [ attribute, nil ]
      end.to_h
    end

    def attributes=(params = {})
      params.each do |attr, value|
        self.public_send("#{attr}=", value) if self.respond_to?("#{attr}=")
      end if params
    end

    def valid_session_fields?
      !( created_at.nil? || cluster_id.nil? || job_id.nil? )
    end

    def user_context
      @user_context ||= user_defined_context_file.exist? ? JSON.parse(user_defined_context_file.read) : {}
    rescue => e
      Rails.logger.error("ERROR: Error parsing user_context file: '#{user_defined_context_file}' --- #{e.class} - #{e.message}")
      {}
    end

    def view
      app.session_view
    end

    class << self
      # The data root directory for this namespace
      # @param token [#to_s] The data root directory for a given app token
      # @return [Pathname] data root directory
      def dataroot(token = "", cluster: nil)
        OodAppkit.dataroot.join('batch_connect').join(cluster.to_s).join(token.to_s)
      end

      # Root directory for file system database
      # @return [Pathname] root directory of file system database
      def db_root
        dataroot.join("db").tap { |p| p.mkpath unless p.exist? }
      end

      # Root directory for file system database
      # @return [Pathname] the cache directory
      def cache_root
        dataroot.join('cache').tap { |p| p.mkpath unless p.exist? }
      end

      # Find all active session jobs
      # @return [Array<Session>] list of sessions
      def all
        db_root.children.select(&:file?).reject do |p| 
          p.extname == ".bak"
        end.map do |f|
          begin
            new.from_json(f.read)
          rescue => e
            Rails.logger.error("ERROR: Error parsing file '#{f}' --- #{e.class} - #{e.message}")
            f.rename("#{f}.bak")
            nil
          end
        end.compact.select do |s| 
          s.valid_session_fields? 
        end.map do |s|
          (s.completed? && s.old? && s.destroy) ? nil : s
        end.compact.sort_by do |s|
          # sort by completed status, then created_at date
          [s.completed? ? 0 : 1, s.created_at]
        end.reverse
      end

      # Find requested session job
      # @return [Session] the session
      def find(id)
        new.from_json(db_root.join(id).read)
      end

      # Checks if a session exists
      # @return [boolean]
      def exist?(id)
        db_root.join(id).exist?
      end

      # How many days before a Session record is considered old and ready to delete
      def old_in_days
        Configuration.ood_bc_card_time
      end
    end

    # Path to database file for this object
    # @return [Pathname, nil] path to db file
    def db_file
      self.class.db_root.join(id) if id
    end

    # The last time the session was updated
    # (which in this case is the database file modified timestamp)
    # @return [Integer] unix timestamp
    def modified_at
      @modified_at ||= (id && File.stat(db_file).mtime.to_i)
    rescue
      nil
    end

    # Return true if session record has not been modified in old_in_days days
    #
    # @return [Boolean] true if old, false otherwise
    def old?
      if modified_at.nil?
        false
      else
        modified_at < self.class.old_in_days.days.ago.to_i
      end
    end

    # Display value for days till old
    #
    # This is 0 if no modified date is available, or if it is old, thus this
    # value should not be used for anything but display purposes.
    #
    # @return [Integer]
    def days_till_old
      if modified_at.nil? || old?
        0
      else
        (modified_at - self.class.old_in_days.days.ago.to_i)/(1.day.to_i)
      end
    end

    # Raised when cluster is not found for specific cluster id
    class ClusterNotFound < StandardError; end

    # Cluster used for controlling job
    # @raise [ClusterNotFound] if cluster is not found from cluster id
    # @return [OodCore::Cluster] cluster
    def cluster
      OodAppkit.clusters[cluster_id] || raise(ClusterNotFound, "Session specifies nonexistent '#{cluster_id}' cluster id.")
    end

    # Raised when user doesn't have access to job adapter on cluster
    class AdapterNotAllowed < StandardError; end

    # Job adapter used for submitting/statusing/deleting jobs
    # @raise [AdapterNotAllowed] if not allowed to use adapter
    # @return [OodCore::Job::Adapter, nil] job adapter
    def adapter
      cluster.job_allow? ? cluster.job_adapter : raise(AdapterNotAllowed, "Session specifies '#{cluster_id}' cluster id that you do not have access to.")
    end

    # The batch connect script template used for creating interactive jobs
    # @param context [#to_h] the context used to render the template
    # @return [OodCore::BatchConnect::Template] batch connect template
    def script_template(context = {})
      cluster.batch_connect_template(template: script_type, **context)
    end

    # Stage and submit a session from an app and its context
    # @param app [BatchConnect::App] batch connect app
    # @param context [BatchConnect::SessionContext] context used for session
    # @param format [String] format used when rendering template
    # @return [Boolean] whether saved successfully
    def save(app:, context:, format: nil)
      self.id         = SecureRandom.uuid
      self.token      = app.token
      self.title      = app.title
      self.created_at = Time.now.to_i
      self.cluster_id = context.try(:cluster).to_s

      submit_script = app.submit_opts(context, fmt: format, staged_root: staged_root) # could raise an exception

      self.cluster_id = submit_script.fetch(:cluster, cluster_id).to_s
      raise(ClusterNotFound, I18n.t('dashboard.batch_connect_missing_cluster')) unless cluster_id.present?

      stage(app.root.join("template"), context: context) && submit(submit_script)
    rescue => e   # rescue from all standard exceptions (app never crashes)
      errors.add(:save, e.message)
      Rails.logger.error("ERROR: #{e.class} - #{e.message}")
      false
    end

    # Stage the app's job template to user's staging directory
    # @param root [#to_s] root directory that gets staged
    # @param context [Object] context available when rendering staged files
    # @return [Boolean] whether staged successfully
    def stage(root, context: nil)
      staged_root.tap { |p| FileUtils.mkdir_p(p.to_s, mode: 0o0700) unless p.exist? }

      # Sync the template files over
      oe, s = Open3.capture2e('rsync', '-rlpv', '--exclude', '.*.swp', '--exclude', '*.erb', "#{root}/", staged_root.to_s)
      raise oe unless s.success?

      # Output user submitted context attributes for debugging purposes
      user_defined_context_file.write(JSON.pretty_generate context.as_json)

      # Render all template files using ERB
      render_erb_files(
        template_files(root),
        root_dir: root,
        binding: TemplateBinding.new(self, context).get_binding
      )
      true
    rescue => e   # rescue from all standard exceptions (app never crashes)
      errors.add(:stage, e.message)
      Rails.logger.error("ERROR: #{e.class} - #{e.message}")
      false
    end

    # Submit session's script to the cluster and record job id to database
    # @param opts [#to_h] app-specific submit hash
    # @return [Boolean] whether submitted successfully
    def submit(opts = {})
      opts = opts.to_h.compact.deep_symbolize_keys
      content = script_content opts.fetch(:batch_connect, {})
      options = script_options opts.fetch(:script, {})

      # Record the job script for debugging purposes
      job_script_content_file.write(content)
      job_script_options_file.write(JSON.pretty_generate(options))

      # Submit job script
      ClimateControl.modify(sanitized_env) do
        self.job_id = adapter.submit script(content: content, options: options)
      end
      db_file.write(to_json, perm: 0o0600)
      true
    rescue => e   # rescue from all standard exceptions (app never crashes)
      errors.add(:submit, e.message)
      Rails.logger.error("ERROR: #{e.class} - #{e.message}")
      false
    end

    # The session's script
    # @param opts [#to_h] script options
    # @option opts [Hash] :content ({}) job script content
    # @option opts [Hash] :options ({}) job script options
    # @return [OodCore::Job::Script] the script object
    def script(opts = {})
      opts = opts.to_h.compact.deep_symbolize_keys
      content = opts.fetch(:content, "")
      options = opts.fetch(:options, {})

      OodCore::Job::Script.new(**options.merge(content: content))
    end

    # The content of the batch script used for this session
    # @param opts [#to_h] batch connect template options
    # @option opts [String] :template ("basic") the batch connect template to
    #   use when generating the batch script
    # @return [String] the rendered batch script
    def script_content(opts = {})
      opts = opts.to_h.compact.deep_symbolize_keys
      self.script_type = opts.fetch(:template, "basic")

      opts = opts.merge(
        work_dir:    staged_root,
        conn_file:   connect_file,
        before_file: before_file,
        script_file: script_file,
        after_file:  after_file,
        clean_file:  clean_file
      )

      script_template(opts).to_s
    end

    # The options used to submit the batch script for this session
    # @param opts [#to_h] supplied script options
    # @return [Hash] the session-specific script options
    def script_options(opts = {})
      opts = opts.to_h.compact.deep_symbolize_keys

      opts = {
        job_name: adapter.sanitize_job_name(job_name),
        workdir: staged_root,
        output_path: output_file,
        shell_path: shell_path
      }.merge opts
    end

    def vnc?
      script_type == "vnc" || script_type == "vnc_container"
    end

    # Cancel this session's job
    # @return [Boolean] whether successfully canceled
    def cancel
      adapter.delete(job_id) unless completed?
      @info = OodCore::Job::Info.new(id: job_id, status: :completed)
      # persist the session state
      update_cache_completed!
      true
    rescue ClusterNotFound, AdapterNotAllowed, OodCore::JobAdapterError => e
      errors.add(:delete, e.message)
      Rails.logger.error(e.message)
      false
    end

    # Terminate this session's job and delete its database record
    # @return [Boolean] whether successfully deleted
    def destroy
      adapter.delete(job_id) unless completed?
      db_file.delete
      true
    rescue ClusterNotFound, AdapterNotAllowed, OodCore::JobAdapterError => e
      errors.add(:delete, e.message)
      Rails.logger.error(e.message)
      false
    end

    # The job's status
    # @return [OodCore::Job::Status] status object
    def status
      info.status
    end

    # The job's info
    # @return [OodCore::Job::Info] info object
    def info
      @info || update_info
    end

    # Force update the job's info
    # @return [OodCore::Job::Info] info object
    def update_info
      if cache_completed
        @info = OodCore::Job::Info.new(id: job_id, status: :completed)
      else
        @info = adapter.info(job_id)
      end
    rescue ClusterNotFound, AdapterNotAllowed, OodCore::JobAdapterError => e
      errors.add(:info, e.message)
      Rails.logger.error(e.message)
      @info = OodCore::Job::Info.new(id: id, status: :undetermined)
    end

    def update_cache_completed!
      if (! cache_completed) && completed?
        self.cache_completed = true
        self.completed_at = Time.now.to_i
        db_file.write(to_json)
      end
    end

    # Whether this session is persisted to the database
    # @return [Boolean] whether persisted
    def persisted?
      db_file && db_file.file?
    end

    # Whether job is queued
    # @return [Boolean] whether queued
    def queued?
      status.queued?
    end

    # Whether job is held
    # @return [Boolean] whether held
    def held?
      status.queued_held?
    end

    # Whether job is suspended
    # @return [Boolean] whether suspended
    def suspended?
      status.suspended?
    end

    # Whether job is running but still hasn't generated the connection file
    # @return [Boolean] whether starting
    def starting?
      if connection_in_info?
        status.queued? && !connect.to_h.compact.empty?
      else
        status.running? && !connect_file.file?
      end
    end

    # Whether job is running and connection file is generated
    # @return [Boolean] whether running
    def running?
      status.running? && !starting?
    end

    # Whether job is completed
    # @return [Boolean] whether completed
    def completed?
      status.completed?
    end

    # Root directory where a job is staged and run in
    # @return [Pathname] staged root directory
    def staged_root
      c = Configuration.per_cluster_dataroot? ? cluster_id : nil
      self.class.dataroot(token, cluster: c).join("output", id)
    end

    # List of template files that need to be rendered
    # @param dir [#Pathname] the directory where the templates exist
    # @return [Array<Pathname>] list of template files
    def template_files(dir)
      Pathname.glob(dir.join("**", "*.erb")).select(&:file?)
    end

    # Path to script that is sourced before main script is forked
    # @return [Pathname] before script file
    def before_file
      staged_root.join("before.sh")
    end

    # Path to script that is forked as the main script
    # @return [Pathname] main script file
    def script_file
      staged_root.join("script.sh")
    end

    # Path to script that is sourced after main script is forked
    # @return [Pathname] after script file
    def after_file
      staged_root.join("after.sh")
    end

    # Path to script that is sourced during clean up portion of batch job
    # @return [Pathname] clean script file
    def clean_file
      staged_root.join("clean.sh")
    end

    # Path to file that describes the attributes in the context object that
    # were defined by the user through the form submission
    # @return [Pathname] user defined context file
    def user_defined_context_file
      staged_root.join("user_defined_context.json")
    end

    # Path to file that describes the job script's content
    # @return [Pathname] batch job script file
    def job_script_content_file
      staged_root.join("job_script_content.sh")
    end

    # Path to file that describes the job script's submission options
    # @return [Pathname] batch job script options file
    def job_script_options_file
      staged_root.join("job_script_options.json")
    end

    # Path to file that contains the connection information
    # @return [Pathname] connection file
    def connect_file
      # flush nfs cache when checking for this file
      staged_root.join("connection.yml").tap { |f| Dir.open(f.dirname.to_s).close }

    rescue StandardError => e
      Rails.logger.error("can't read connection file because of error '#{e.message}'")
      Pathname.new('/dev/null')
    end

    # Path to file that job pipes stdout/stderr to
    # @return [Pathname] output file
    def output_file
      staged_root.join("output.log")
    end

    # Path to login shell used by the script
    # @return [Pathname] shell path
    def shell_path
      Configuration.disable_bc_shell? ? nil : Pathname.new('/bin/bash')
    end

    # The connection information for this session (job must be running)
    # @return [OpenStruct] connection information
    def connect
      if connection_in_info?
        OpenStruct.new(info.ood_connection_info || {})
      else
        OpenStruct.new YAML.safe_load(connect_file.read)
      end
    end

    # Whether the session info has connection information
    # @return [Boolean] whether there is host and port information in this session.
    def connection_in_info?
      info.respond_to?(:ood_connection_info)
    end

    # Whether to allow SSH to node running the job
    # @return [Boolean] whether to allow SSH to node running the job
    def ssh_to_compute_node?
      return cluster_and_app_ssh? if override_global_ssh_to_compute_node?
      global_ssh_to_compute_node?
    end

    def cluster_and_app_ssh?
      cluster_ssh_to_compute_node && app_ssh_to_compute_node
    end

    def override_global_ssh_to_compute_node?
      cluster_override_ssh_to_compute_node? || app_override_ssh_to_compute_node?
    end

    def cluster_override_ssh_to_compute_node?
      !cluster_ssh_to_compute_node.nil? &&
        cluster_ssh_to_compute_node != global_ssh_to_compute_node?
    end

    def app_override_ssh_to_compute_node?
      !app_ssh_to_compute_node.nil? &&
        app_ssh_to_compute_node != global_ssh_to_compute_node?
    end

    # @return [Boolean]
    def cluster_ssh_to_compute_node
      cluster.batch_connect_ssh_allow?
    rescue ClusterNotFound
      return nil
    end

    # @return [Boolean]
    def app_ssh_to_compute_node
      token.nil? ? true : app.ssh_allow?
    end

    # @return [Boolean]
    def global_ssh_to_compute_node?
      Configuration.ood_bc_ssh_to_compute_node
    end

    # A unique identifier that details the current state of a session
    # @return [String] hash of session
    def to_hash
      hsh = {
        id: id,
        status: status.to_sym,
        connect: running? ? connect.to_h : nil,
        time: info.wallclock_time.to_i / 60     # only update every minute
      }
      Digest::SHA1.hexdigest(hsh.to_json)
    end

    private
      # Namespace the job name
      def job_name
        [
          ENV["OOD_PORTAL"],    # the OOD portal id
          ENV["RAILS_RELATIVE_URL_ROOT"].to_s.sub(/^\/[^\/]+\//, ""),  # the OOD app
          token                 # the Batch Connect app
        ].reject(&:blank?).join("/")
      end

      # Render a list of files using ERB. Note the input .erb files are the system
      # installed erb files (/var/www/ood/...). These are rendered and output into
      # the staged_root.
      def render_erb_files(input_files, binding: nil, remove_extension: true, output_dir: staged_root, root_dir: nil)
        input_files.each do |file|
          template = file.read
          rendered = ERB.new(template, trim_mode: "-").result(binding)

          relative_fname = file.to_s.delete_prefix("#{root_dir}/")
          output_file = output_dir.join(relative_fname)
          output_file = remove_extension ? output_file.sub_ext('') : output_file

          output_file.write(rendered)
          output_file.chmod(file.stat.mode)
        end
      end
  end
end
