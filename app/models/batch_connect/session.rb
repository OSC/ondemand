module BatchConnect
  class Session
    include ActiveModel::Model
    include ActiveModel::Serializers::JSON

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
    # @return [Fixnum] created at
    attr_accessor :created_at

    # Token describing app and sub app
    # @return [String] app token
    attr_accessor :token

    # The title for the session
    # @return [String] session title
    attr_accessor :title

    # The view used to display the connection information for this session
    # @return [String, nil] session view
    attr_accessor :view

    # Batch connect script type
    # @return [String] script type
    attr_accessor :script_type

    # Attributes used for serialization
    # @return [Hash] attributes to be serialized
    def attributes
      %w(id cluster_id job_id created_at token title view script_type).map do |attribute|
        [ attribute, nil ]
      end.to_h
    end

    def attributes=(params = {})
      params.each do |attr, value|
        self.public_send("#{attr}=", value) if self.respond_to?("#{attr}=")
      end if params
    end

    class << self
      # The data root directory for this namespace
      # @param token [#to_s] The data root directory for a given app token
      # @return [Pathname] data root directory
      def dataroot(token = "")
        OodAppkit.dataroot.join("batch_connect", token.to_s)
      end

      # Root directory for file system database
      # @return [Pathname] root directory of file system database
      def db_root
        dataroot.join("db").tap { |p| p.mkpath unless p.exist? }
      end

      # Find all active session jobs
      # @return [Array<Session>] list of sessions
      def all
        db_root.children.select(&:file?).map do |f|
          new.from_json(f.read)
        end.map do |s|
          s.completed? && s.destroy ? nil : s
        end.compact.sort_by(&:created_at).reverse
      end

      # Find requested session job
      # @return [Session] the session
      def find(id)
        new.from_json(db_root.join(id).read)
      end
    end

    # Path to database file for this object
    # @return [Pathname, nil] path to db file
    def db_file
      self.class.db_root.join(id) if id
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
      self.cluster_id = app.cluster_id
      self.token      = app.token
      self.title      = app.title
      self.view       = app.session_view
      self.created_at = Time.now.to_i

      stage(root: app.root.join("template")) &&
        submit(app.submit_opts(context, fmt: format))
    end

    # Stage the app's job template to user's staging directory
    # @param root [#to_s] root directory that gets staged
    # @return [Boolean] whether staged successfully
    def stage(root:)
      oe, s = Open3.capture2e("rsync -av --delete #{root}/ #{staged_root}")
      unless s.success?
        errors.add(:stage, oe)
        Rails.logger.error(oe)
      end
      s.success?
    end

    # Submit session's script to the cluster and record job id to database
    # @param opts [#to_h] script options
    # @return [Boolean] whether submitted successfully
    def submit(script_opts = {})
      self.job_id = adapter.submit script(script_opts)
      db_file.write(to_json)
      true
    rescue ClusterNotFound, AdapterNotAllowed, OodCore::JobAdapterError => e
      output_root.rmtree
      errors.add(:submit, e.message)
      Rails.logger.error(e.message)
      false
    end

    # The session's script
    # @param opts [#to_h] script options
    # @option opts [Hash] :batch_connect ({}) batch connect template options
    # @option opts [Hash] :script ({}) job script options
    # @return [OodCore::Job::Script] the script
    def script(opts = {})
      opts = opts.to_h.deep_symbolize_keys
      bc_opts     = opts.fetch(:batch_connect, { template: :basic })
      script_opts = opts.fetch(:script, {})

      # Add adapter specific options
      case cluster.job_config[:adapter]
      when "torque"
        script_opts = {
          native: {
            headers: {
              Shell_Path_List: "/bin/bash"
            }
          }
        }.deep_merge script_opts
      when "slurm"
        # slurm sets the shell from the shebang of the script
      when "lsf"
        # hopefully lsf also sets the shell from the shebang
      end

      OodCore::Job::Script.new(
        {
          content: script_content(bc_opts),
          job_name: job_name,
          workdir: output_root,
          output_path: output_file
        }.merge script_opts
      )
    end

    # The content of the batch script used for this session
    # @param opts [#to_h] batch connect template options
    # @option opts [String] :template ("basic") the batch connect template to
    #   use when generating the batch script
    # @return [String] the rendered batch script
    def script_content(opts = {})
      opts = opts.to_h.deep_symbolize_keys
      self.script_type = opts.fetch(:template, "basic")

      opts = opts.merge(
        work_dir:    output_root,
        conn_file:   connect_file,
        before_file: staged_root.join("before.sh"),
        script_file: staged_root.join("script.sh"),
        after_file:  staged_root.join("after.sh"),
        clean_file:  staged_root.join("clean.sh"),
      )

      script_template(opts).to_s
    end

    # Delete this session's job and database record
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
      @info = adapter.info(job_id)
    rescue ClusterNotFound, AdapterNotAllowed, OodCore::JobAdapterError => e
      errors.add(:info, e.message)
      Rails.logger.error(e.message)
      @info = OodCore::Job::Info.new(id: id, status: :undetermined)
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
      status.running? && !connect_file.file?
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

    # Root directory that mirrors the batch connect app's job template
    # @return [Pathname] staged root directory
    def staged_root
      self.class.dataroot(token).join("staged").tap { |p| p.mkpath unless p.exist? }
    end

    # Root directory for a job's output files
    # @return [Pathname] output root directory
    def output_root
      self.class.dataroot(token).join("output", id).tap { |p| p.mkpath unless p.exist? }
    end

    # Path to file that contains the connection information
    # @return [Pathname] connection file
    def connect_file
      # flush nfs cache when checking for this file
      output_root.join("connection.yml").tap { |f| Dir.open(f.dirname.to_s).close }
    end

    # Path to file that job pipes stdout/stderr to
    # @return [Pathname] output file
    def output_file
      output_root.join("output.log")
    end

    # The connection information for this session (job must be running)
    # @return [OpenStruct] connection information
    def connect
      OpenStruct.new YAML.safe_load(connect_file.read)
    end

    # A unique identifier that details the current state of a session
    # @return [String] hash of session
    def to_hash
      hsh = {
        id: id,
        status: status.to_sym,
        connect: running? ? connect.to_h : nil
      }
      Digest::MD5.hexdigest(hsh.to_json)
    end

    private
      # Namespace the job name
      def job_name
        [
          ENV["OOD_PORTAL"],    # the OOD portal id
          ENV["RAILS_RELATIVE_URL_ROOT"].sub(/^\/[^\/]+\//, ""),  # the OOD app
          token                 # the Batch Connect app
        ].reject(&:blank?).join("/")
      end
  end
end
