# frozen_string_literal: true

require 'smart_attributes'

module BatchConnect
  # This is the model representing a batch connect app. It's mostly a data object
  # holding and interpreting the configurations (notable form.yml.erb) and rendering
  # submit options based off of what's been chosen by the user.
  class App < OodApp
    # Router for a deployed batch connect app
    # @return [DevRouter, UsrRouter, SysRouter] router for batch connect app
    attr_accessor :router

    # The sub app
    # @return [String, nil] sub app
    attr_accessor :sub_app

    # Raised when batch connect app components could not be found
    class AppNotFound < StandardError; end

    include EncryptedCache

    class << self
      # Generate an object from a token
      # @param token [String] the token
      # @return [App] generated object
      def from_token(token)
        type, *app = token.split('/')
        case type
        when 'dev'
          name, sub_app = app
          router = DevRouter.new(name)
        when 'usr'
          owner, name, sub_app = app
          router = UsrRouter.new(name, owner)
        else # "sys"
          name, sub_app = app
          router = SysRouter.new(name)
        end
        new(router: router, sub_app: sub_app)
      end
    end

    # @param router [DevRouter, UsrRouter, SysRouter] router for batch connect
    #   app
    # @param sub_app [String, nil] sub app
    def initialize(router: nil, sub_app: nil)
      super(router)
      @sub_app = sub_app&.to_s

      # read the form config now so it's there when this object is cached in upper layers.
      form_config
    end

    # Generate a token from this object
    # @return [String] token
    def token
      [router.token, sub_app].compact.join('/')
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
        root.join('local')
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
      title  = OodApp.instance_method(:title).bind(self).call
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
      OodApp.instance_method(:manifest).bind(self).call.description
    end

    def icon_uri
      form_config.fetch(:icon, super)
    end

    def caption
      form_config.fetch(:caption, super)
    end

    def tile
      super.merge(form_config.fetch(:tile, {}))
    end

    def category
      form_config.fetch(:category, super)
    end

    def subcategory
      form_config.fetch(:subcategory, super)
    end

    def metadata
      parent_md = OodApp.instance_method(:metadata).bind(self).call
      parent_md.merge(form_config.fetch(:metadata, {}))
    end

    def form_header
      form_config.fetch(:form_header, '')
    end

    def ssh_allow?
      form_config[:ssh_allow]
    end

    def link
      OodAppLink.new(
        # FIXME: better to use default_title and "" description
        title:       title,
        description: description,
        url:         url,
        icon_uri:    icon_uri,
        caption:     caption,
        new_tab:     false,
        data:        preset? ? { 'method': 'post' } : {},
        tile:        tile
      )
    end

    # The clusters the batch connect app is configured to use
    # @return [Array<String>, []] the clusters the app wants to use
    def configured_clusters
      Array.wrap(form_config.fetch(:cluster, nil))
           .reject { |c| c.to_s.strip.empty? }
           .map { |c| c.to_s.strip }
           .compact
    end

    # Read in context from cache file if cache is disabled and context.json exist
    def update_session_with_cache(session_context, cache_file)
      cache = cache_file.file? ? JSON.parse(cache_file.read) : {}
      cache.delete('cluster') if delete_cached_cluster?(cache['cluster'].to_s)
      cache = cache.symbolize_keys

      cache = decypted_cache_data(app: self, data: cache)

      session_context.update_with_cache(cache)
    end

    def delete_cached_cluster?(cached_cluster)
      # if you've cached a cluster that no longer exists
      !OodAppkit.clusters.include?(cached_cluster) ||
        # OR the app only has 1 cluster, and it's changed since the previous cluster was cached.
        # I.e., admin wants to override what you've cached.
        (clusters.size == 1 && clusters[0] != cached_cluster)
    end

    # The clusters that the batch connect app can use. It's a combination
    # of what the app is configured to use and what the user is allowed
    # to use. If the app has clusters configured, it preserves the order
    # when it can. glob configurations' order may be platform dependent.
    #
    # @return [Array<OodCore::Cluster>] clusters available to the app user
    def clusters
      @clusters ||=
        configured_clusters.map do |config|
          cfg_to_clusters(config)
        end.flatten.compact.select(&:job_allow?)
    end

    def preset?
      return false unless valid?
      return true if attributes.all?(&:fixed?)

      # clusters can be hidden field which is not fixed, so we have to account for that.
      cluster = attributes.find { |a| a.id == 'cluster' }
      attributes.reject { |a| a.id == 'cluster' }.all?(&:fixed?) && cluster.widget == 'hidden_field'
    end

    # Whether this is a valid app the user can use
    # @return [Boolean] whether valid app
    def valid?
      if form_config.empty?
        false
      elsif !form_config.fetch(:form, []).is_a?(Array)
        @validation_reason = I18n.t('dashboard.batch_connect_invalid_form_array')
        false
      elsif !form_config.fetch(:attributes, {}).is_a?(Hash)
        @validation_reason = I18n.t('dashboard.batch_connect_invalid_form_attributes')
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
        'This app does not specify any cluster.'
      elsif clusters.empty?
        'This app requires clusters that do not exist ' \
          'or you do not have access to.'
      else
        ''
      end
    end

    def attributes
      @attributes ||= begin
        return [] unless valid?

        local_attribs = form_config.fetch(:attributes, {})
        attrib_list   = form_config.fetch(:form, [])
        add_cluster_widget(local_attribs, attrib_list)

        attrib_list.map do |attribute_id|
          attribute_opts = local_attribs.fetch(attribute_id.to_sym, {})

          # Developer wanted a fixed value
          attribute_opts = { value: attribute_opts, fixed: true } unless attribute_opts.is_a?(Hash)

          # Hide resolution if not using native vnc clients
          if attribute_id.to_s == 'bc_vnc_resolution' && !ENV['ENABLE_NATIVE_VNC']
            attribute_opts = { value: nil, fixed: true }
          end

          SmartAttributes::AttributeFactory.build(attribute_id, attribute_opts)
        end
      end
    end

    # The session context described by this batch connect app
    # @return [SessionContext] the session context
    def build_session_context
      attributes.each(&:validate!)
      BatchConnect::SessionContext.new(attributes, form_config.fetch(:cacheable, nil))
    end

    #
    # Generate a hash of the submission options
    # @param session_context [SessionContext] object with attributes
    # @param fmt [String, nil] formatting used for attributes in submit hash
    # @param staged_root [String, nil] the staged_root you want to pass into the submit_opts
    # @return [Hash] hash of submission options
    def submit_opts(session_context, fmt: nil, staged_root: nil)
      hsh = {}
      session_context.each do |attribute|
        hsh = hsh.deep_merge attribute.submit(fmt: fmt)
      end

      struct = session_context.to_openstruct(addons: { staged_root: staged_root })
      ctx_binding = struct.instance_eval { binding }
      hsh.deep_merge(submit_config(binding: ctx_binding))

    # let's write the file out if it's a submit.yml.erb that isn't valid yml
    rescue Psych::SyntaxError => e
      unless staged_root.nil?
        yml = submit_file(root: root)
        bad_content = render_erb_file(path: yml, contents: yml.read, binding: ctx_binding)
        Pathname.new(staged_root).tap { |p| p.mkpath unless p.exist? }
        File.open("#{staged_root}/submit.yml", 'w+') { |file| file.write(bad_content) }
      end

      raise e
    end

    # View used for session if it exists
    # @return [String, nil] session view
    def session_view
      file = root.join('view.html.erb')
      file.read if file.file?
    end

    # View used for session info if it exists
    # @return [String, nil] session info
    def session_info_view
      @session_info_view ||= Pathname.new(root).glob('info.{md,html}.erb').find(&:file?).try(:read)
    rescue StandardError
      nil
    end

    # Completed view used for session info if it exists
    # @return [String, nil] session info
    def session_completed_view
      @session_completed_view ||= Pathname.new(root).glob('completed.{md,html}.erb').find(&:file?).try(:read)
    rescue StandardError
      nil
    end

    # Paths to custom javascript files
    # @return [Pathname] paths to custom javascript files that exist
    def custom_javascript_files
      files = [root.join('form.js')]
      files << sub_app_root.join("#{sub_app}.js")
      files.select(&:file?)
    end

    # List of sub apps that are owned by the parent batch connect app
    # (including this app as well)
    # @return [Array<App>] list of sub apps
    def sub_app_list
      @sub_app_list ||= build_sub_app_list
    end

    def has_sub_apps?
      sub_app_list.size > 1 || sub_app_list[0] != self
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

    def cache_file
      "#{token.gsub('/', '_')}.json"
    end

    private

    def url
      helpers = Rails.application.routes.url_helpers

      if preset?
        helpers.batch_connect_session_contexts_path(token: token)
      else
        helpers.new_batch_connect_session_context_path(token: token)
      end
    end

    def cfg_to_clusters(config)
      c = OodAppkit.clusters[config.to_sym] || nil
      return [c] unless c.nil?

      # cluster may be a glob at this point
      OodAppkit.clusters.select do |cluster|
        File.fnmatch(config, cluster.id.to_s, File::FNM_EXTGLOB)
      end
    end

    def build_sub_app_list
      return [self] unless sub_app_root.directory? && sub_app_root.readable? && sub_app_root.executable?

      list = sub_app_root.children.select(&:file?).map do |f|
        root = f.dirname
        name = f.basename.to_s.split('.').first
        file = form_file(root: root, name: name)
        self.class.new(router: router, sub_app: name) if f == file
      end.compact
      list.empty? ? [self] : list.sort_by(&:sub_app)
    end

    # Path to file describing form hash
    def form_file(root:, name: 'form')
      ["#{name}.yml.erb", "#{name}.yml"].map { |f| root.join(f) }.select(&:file?).first
    end

    # Path to file describing submission hash
    # rubocop:disable Style/WordArray - solargraph has a bug with ['arrays', 'like', 'this']
    def submit_file(root:, paths: %w[submit.yml.erb submit.yml])
      # rubocop:enable Style/WordArray
      Array.wrap(paths).compact.map { |f| root.join(f) }.select(&:file?).first
    end

    # Parse an ERB and Yaml file
    def read_yaml_erb(path:, binding: nil)
      contents = path.read
      contents = render_erb_file(path: path, contents: contents, binding: binding) if path.extname == '.erb'
      YAML.safe_load(contents).to_h.deep_symbolize_keys
    end

    # pure function to render erb, properly setting the filename attribute
    # before rendering
    def render_erb_file(path:, contents:, binding:)
      erb = ERB.new(contents, trim_mode: '-')
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
        unless file
          msg = "This app does not supply a sub app form file under the directory '#{sub_app_root}'"
          raise AppNotFound, msg
        end

        hsh = hsh.deep_merge read_yaml_erb(path: file, binding: binding)
      end
      @form_config = hsh
    rescue AppNotFound => e
      @validation_reason = e.message
      {}
    rescue StandardError, Exception => e
      @validation_reason = "#{e.class.name}: #{e.message}"
      {}
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

    # add a widget for choosing the cluster if one doesn't already exist
    # and if users aren't defining they're own form.cluster and attributes.cluster
    def add_cluster_widget(attributes, attribute_list)
      return unless clusters.any?

      attribute_list.prepend('cluster') unless attribute_list.include?('cluster')

      attributes[:cluster] = if clusters.size > 1
                               {
                                 widget:  'select',
                                 label:   'Cluster',
                                 options: clusters.map(&:id)
                               }
                             else
                               {
                                 value:  clusters.first.id.to_s,
                                 widget: 'hidden_field'
                               }
                             end
    end
  end
end
