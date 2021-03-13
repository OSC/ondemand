require "smart_attributes"

module BatchConnect
  class App
    # Router for a deployed batch connect app
    # @return [DevRouter, UsrRouter, SysRouter] router for batch connect app
    attr_accessor :router

    # The sub app
    # @return [String, nil] sub app
    attr_accessor :sub_app

    delegate :type, :category, :subcategory, :metadata, to: :ood_app

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
      if Configuration.load_external_bc_config? && router.type == :sys && global_sub_app_root.directory?
        global_sub_app_root
      else
        root.join("local")
      end
    end

    # Global root path to the sub apps
    # @return [Pathname] global root directory of sub apps
    def global_sub_app_root
      Configuration.bc_config_root.join(router.name)
    end

    # Title for the batch connect app
    # @return [String] title of app
    def title
      form_config.fetch(:title, default_title)
    end

    # Default title for the batch connect app
    # @return [String] default title of app
    def default_title
      title  = ood_app.title
      title += ": #{sub_app.titleize}" if sub_app
      title
    end

    # Description for the batch connect app
    # @return [String] description of app
    def description
      form_config.fetch(:description, default_description)
    end

    # Default description for the batch connect app
    # @return [String] default description of app
    def default_description
      ood_app.manifest.description
    end

    def link
      OodAppLink.new(
        # FIXME: better to use default_title and "" description
        title: title,
        description: description,
        url: Rails.application.routes.url_helpers.new_batch_connect_session_context_path(token: token),
        icon_uri: ood_app.icon_uri,
        caption: ood_app.caption,
        new_tab: false
      )
    end

    # The clusters the batch connect app is configured to use
    # @return [Array<String>, []] the clusters the app wants to use
    def configured_clusters
      Array.wrap(form_config.fetch(:cluster, nil))
        .select { |c| !c.to_s.strip.empty? }
        .map { |c| c.to_s.strip }
        .compact
    end

    # Wheter the cluster is allowed or not based on the configured
    # clusters and if the cluster allows jobs (job_allow?)
    #
    # @return [Boolean] whether the cluster is allowed or not
    def cluster_allowed(cluster)
      cluster.job_allow? && configured_clusters.any? do |pattern|
        File.fnmatch(pattern, cluster.id.to_s, File::FNM_EXTGLOB)
      end
    end
    
    # Read in context from cache file if cache is disabled and context.json exist
    def update_session_with_cache(session_context, cache_file)
      cache = cache_file.file? ? JSON.parse(cache_file.read) : {}
      cache.delete('cluster') if delete_cached_cluster?(cache['cluster'].to_s)

      session_context.update_with_cache(cache)
    end

    def delete_cached_cluster?(cached_cluster)

      # if you've cached a cluster that no longer exists
      !OodAppkit.clusters.include?(cached_cluster) ||
        # OR the app only has 1 cluster, and it's changed since the previous cluster was cached.
        # I.e., admin wants to override what you've cached.
        (self.clusters.size == 1 && self.clusters[0] != cached_cluster)
    end


    # The clusters that the batch connect app can use. It's a combination
    # of what the app is configured to use and what the user is allowed
    # to use.
    # @return [OodCore::Clusters] clusters available to the app user
    def clusters
      OodAppkit.clusters.select { |cluster| cluster_allowed(cluster) }
    end

    # Whether this is a valid app the user can use
    # @return [Boolean] whether valid app
    def valid?
      if form_config.empty?
        false
      elsif configured_clusters.any?
        clusters.any?
      else
        true
      end
    end

    # The reason why this app may or may not be valid
    # @return [String] reason why not valid
    def validation_reason
      return @validation_reason if @validation_reason

      if configured_clusters.empty?
        "This app does not specify any cluster."
      elsif clusters.empty?
        "This app requires clusters that do not exist " +
        "or you do not have access to."
      else
        ""
      end
    end
    
    # The session context described by this batch connect app
    # @return [SessionContext] the session context
    def build_session_context

      local_attribs = form_config.fetch(:attributes, {})
      attrib_list   = form_config.fetch(:form, [])
      add_cluster_widget(local_attribs, attrib_list)
      attributes = attrib_list.map do |attribute_id|
        attribute_opts = local_attribs.fetch(attribute_id.to_sym, {})

        # Developer wanted a fixed value
        attribute_opts = { value: attribute_opts, fixed: true } unless attribute_opts.is_a?(Hash)

        # Hide resolution if not using native vnc clients
        attribute_opts = { value: nil, fixed: true } if attribute_id.to_s == "bc_vnc_resolution" && !ENV["ENABLE_NATIVE_VNC"]

        SmartAttributes::AttributeFactory.build(attribute_id, attribute_opts)
      end

     BatchConnect::SessionContext.new(attributes, form_config.fetch(:cacheable, nil)  ) #form_config.fetch(:cacheable, nil)  
       
    end

    #
    # Generate a hash of the submission options
    # @param session_context [SessionContext] object with attributes
    # @param fmt [String, nil] formatting used for attributes in submit hash
    # @return [Hash] hash of submission options
    def submit_opts(session_context, staged_root: staged_root, fmt: nil)
      hsh = {}
      session_context.each do |attribute|
        hsh = hsh.deep_merge attribute.submit(fmt: fmt)
      end

      # rendering context should be attribute values AND staged_root
      # so we convert the array of Attribute objects to a Hash of id => value pairs
      # and convert that to an OpenStruct, which gives the same "attribute_name as method" experience,
      # lets us add staged_root, and avoids conflicts with other predefined methods like partition
      # (OpenStruct has very few)
      context_attrs = Hash[*(session_context.map {|a| [a.id, a.value] }.flatten)]
      illegal_attrs = OpenStruct.new.methods & context_attrs.keys

      raise '#{illegal_attrs.inspect} are keywords that cannot be used as attr names' unless illegal_attrs.empty?

      rendering_context = OpenStruct.new(context_attrs)
      rendering_context.staged_root = staged_root

      rendering_context.define_singleton_method(:get_binding) { binding }

      hsh = hsh.deep_merge submit_config(binding: rendering_context.get_binding)
    end

    # View used for session if it exists
    # @return [String, nil] session view
    def session_view
      file = root.join("view.html.erb")
      file.read if file.file?
    end

    # View used for session info if it exists
    # @return [String, nil] session info
    def session_info_view
      @session_info_view ||= Pathname.new(root).glob("info.{md,html}.erb").find(&:file?).try(:read)
    rescue
      nil
    end

    # Paths to custom javascript files
    # @return [Pathname] paths to custom javascript files that exist
    def custom_javascript_files
      files = [root.join("form.js")]
      files << sub_app_root.join("#{sub_app}.js")
      files.select(&:file?)
    end

    # List of sub apps that are owned by the parent batch connect app
    # (including this app as well)
    # @return [Array<App>] list of sub apps
    def sub_app_list
      @sub_app_list ||= build_sub_app_list
    end

    # The version of the OodApp
    # @return [String] the version
    def version
      @ood_app.version
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
        return [self] unless sub_app_root.directory? && sub_app_root.readable? && sub_app_root.executable?
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
        contents = render_erb_file(path: path, contents: contents, binding: binding) if path.extname == ".erb"
        YAML.safe_load(contents).to_h.deep_symbolize_keys
      end

      # pure function to render erb, properly setting the filename attribute
      # before rendering
      def render_erb_file(path:, contents:, binding:)
        erb = ERB.new(contents, nil, "-")
        erb.filename = path.to_s
        erb.result(binding)
      end

      # Hash describing the full form object
      def form_config(binding: nil)
        return @form_config if @form_config

        raise AppNotFound, "This app does not exist under the directory '#{root}'" unless root.directory?
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

      # The OOD app object describing this app
      def ood_app
        @ood_app ||= OodApp.new(router)
      end

      # add a widget for choosing the cluster if one doesn't already exist
      # and if users aren't defining they're own form.cluster and attributes.cluster
      def add_cluster_widget(attributes, attribute_list)
        return unless configured_clusters.any?

        attribute_list.prepend("cluster") unless attribute_list.include?("cluster")

        if clusters.size > 1
          attributes[:cluster] = {
            widget: "select",
            label: "Cluster",
            options: clusters.map { |cluster| cluster.id.to_s }
          }
        else
          attributes[:cluster] = {
            value: clusters.first.id.to_s,
            widget: "hidden_field"
          }
        end
      end
  end
end
