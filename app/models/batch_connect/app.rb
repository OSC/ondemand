require "smart_attributes"

module BatchConnect
  class App
    # Router for a deployed batch connect app
    # @return [DevRouter, UsrRouter, SysRouter] router for batch connect app
    attr_accessor :router

    # The sub app
    # @return [String, nil] sub app
    attr_accessor :sub_app

    # Raised when batch connect app components could not be found
    class AppNotFound < StandardError; end

    class << self
      # Generate an object from a token
      # @param token [String] the token
      # @return [App] generated object
      def from_token(token)
        type, *app = token.split("/")
        case type
        when "dev"
          name, sub_app = app
          router = DevRouter.new(name)
        when "usr"
          owner, name, sub_app = app
          router = UsrRouter.new(name, owner)
        else  # "sys"
          name, sub_app = app
          router = SysRouter.new(name)
        end
        new(router: router, sub_app: sub_app)
      end
    end

    # @param router [DevRouter, UsrRouter, SysRouter] router for batch connect
    #   app
    # @param sub_app [String, nil] sub app
    def initialize(router:, sub_app: nil)
      @router  = router
      @sub_app = sub_app && sub_app.to_s
    end

    # Generate a token from this object
    # @return [String] token
    def token
      [router.token, sub_app].compact.join("/")
    end

    # Get the token for this app, excluding the subapp
    # @return [String] token
    def base_token
      router.token
    end

    # Root path to batch connect app
    # @return [Pathname] root directory of batch connect app
    def root
      router.path
    end

    # Root path to the sub apps
    # @return [Pathname] root directory of sub apps
    def sub_app_root
      root.join("local")
    end

    # Title for the batch connect app
    # @return [String] title of app
    def title
      form_config.fetch(:title, default_title)
    end

    # Default title for the batch connect app
    # @return [String] default title of app
    def default_title
      sub_app ? sub_app.titleize : root.basename.to_s.titleize
    end

    # Description for the batch connect app
    # @return [String] description of app
    def description
      form_config.fetch(:description, "")
    end

    # Cluster id the batch connect app uses
    # @return [String, nil] cluster id used by app
    def cluster_id
      form_config.fetch(:cluster, nil)
    end

    # The cluster that the batch connect app uses
    # @return [OodCore::Cluster, nil] cluster that app uses
    def cluster
      OodAppkit.clusters[cluster_id] if cluster_id
    end

    # Whether this is a valid app the user can use
    # @return [Boolean] whether valid app
    def valid?
      (! form_config.empty?) && cluster && cluster.job_allow?
    end

    # The reason why this app may or may not be valid
    # @return [String] reason why not valid
    def validation_reason
      return @validation_reason if @validation_reason

      if !cluster_id
        "This app does not specify a cluster."
      elsif !cluster
        "This app requires a cluster that does not exist."
      elsif !cluster.job_allow?
        "You do not have access to use this app."
      else
        ""
      end
    end

    # The session context described by this batch connect app
    # @return [SessionContext] the session context
    def build_session_context
      local_attribs = form_config.fetch(:attributes, {})
      attrib_list   = form_config.fetch(:form, [])
      BatchConnect::SessionContext.new(
        attrib_list.map do |attribute_id|
          attribute_opts = local_attribs.fetch(attribute_id.to_sym, {})

          # Developer wanted a fixed value
          attribute_opts = { value: attribute_opts, fixed: true } unless attribute_opts.is_a?(Hash)

          # Hide resolution if not using native vnc clients
          attribute_opts = { value: nil, fixed: true } if attribute_id.to_s == "bc_vnc_resolution" && !ENV["ENABLE_NATIVE_VNC"]

          SmartAttributes::AttributeFactory.build(attribute_id, attribute_opts)
        end
      )
    end

    # Generate a hash of the submission options
    # @param session_context [SessionContext] object with attributes
    # @param fmt [String, nil] formatting used for attributes in submit hash
    # @return [Hash] hash of submission options
    def submit_opts(session_context, fmt: nil)
      hsh = {}
      session_context.each do |attribute|
        hsh = hsh.deep_merge attribute.submit(fmt: fmt)
      end
      hsh = hsh.deep_merge submit_config(binding: session_context.get_binding)
    end

    # View used for session if it exists
    # @return [String, nil] session view
    def session_view
      file = root.join("view.html.erb")
      file.read if file.file?
    end

    # List of sub apps that are owned by the parent batch connect app
    # (including this app as well)
    # @return [Array<App>] list of sub apps
    def sub_app_list
      @sub_app_list ||= build_sub_app_list
    end

    # Convert object to string
    # @return [String] the string describing this object
    def to_s
      token
    end

    # The comparison operator
    # @param other [#to_s] object to compare against
    # @return [Boolean] whether objects are equivalent
    def ==(other)
      token == other.to_s
    end

    private
      def build_sub_app_list
        return [self] unless sub_app_root.directory?
        list = sub_app_root.children.select(&:file?).map do |f|
          root = f.dirname
          name = f.basename.to_s.split(".").first
          file = form_file(root: root, name: name)
          self.class.new(router: router, sub_app: name) if f == file
        end.compact
        list.empty? ? [self] : list.sort_by(&:sub_app)
      end

      # Path to file describing form hash
      def form_file(root:, name: "form")
        %W(#{name}.yml.erb #{name}.yml).map { |f| root.join(f) }.select(&:file?).first
      end

      # Path to file describing submission hash
      def submit_file(root:, paths: %w(submit.yml.erb submit.yml))
        Array.wrap(paths).compact.map { |f| root.join(f) }.select(&:file?).first
      end

      # Parse an ERB and Yaml file
      def read_yaml_erb(path:, binding: nil)
        contents = path.read
        contents = ERB.new(contents, nil, "-").result(binding) if path.extname == ".erb"
        YAML.safe_load(contents).to_h.deep_symbolize_keys
      end

      # Hash describing the full form object
      def form_config(binding: nil)
        return @form_config if @form_config

        file = form_file(root: root)
        raise AppNotFound, "This app does not supply a form file under the directory '#{root}'" unless file
        hsh = read_yaml_erb(path: file, binding: binding)
        if sub_app
          file = form_file(root: sub_app_root, name: sub_app)
          raise AppNotFound, "This app does not supply a sub app form file under the directory '#{sub_app_root}'" unless file
          hsh = hsh.deep_merge read_yaml_erb(path: file, binding: binding)
        end
        @form_config = hsh
      rescue AppNotFound => e
        @validation_reason = e.message
        return {}
      rescue => e
        @validation_reason = "#{e.class.name}: #{e.message}"
        return {}
      end

      # Hash describing the full submission properties
      def submit_config(binding: nil)
        return @submit_config if @submit_config

        file = submit_file(root: root)
        hsh = file ? read_yaml_erb(path: file, binding: binding) : {}
        if path = form_config.fetch(:submit, nil)
          file = submit_file(root: sub_app_root, paths: path)
          hsh = hsh.deep_merge read_yaml_erb(path: file, binding: binding) if file
        end
        @submit_config = hsh
      end
  end
end
