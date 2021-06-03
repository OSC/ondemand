class LauncherButton

  def self.launchers
    app_launchers = ::Configuration.launchers.map{ |system_launcher| LauncherButton.new({ type: "system" }, system_launcher) }

    #EXTERNAL CONFIGURED LAUNCHERS
    ::Configuration.launchers_path.each do |path_string|
      launcher_path = Pathname.new(path_string)
      if launcher_path.directory? && launcher_path.readable?
        launcher_path.children.each do |launcher_file|
          app_launchers.concat parse_launcher_file(launcher_file: launcher_file)
        end
      end
    end

    #ODER BY order field. ITEMS WITHOUT order field WILL GO LAST
    app_launchers.compact.sort
  end

  def initialize(metadata, config)
    @metadata = metadata
    @form = config[:form]
    @view = config[:view]

    @metadata[:id] = config[:id]&.downcase

    raise ArgumentError, "launch button config must defined an id metadata=#{metadata}" unless @metadata[:id]
    raise ArgumentError, "launch button config must defined a token field id=#{@metadata[:id]} metadata=#{metadata}" unless @form[:token]

    set_cluster
    @metadata[:order] = config[:order]
    @metadata[:status] = config[:status] ? config[:status].downcase : "active"
  end

  def id
    return @metadata[:id]
  end

  def order
    return @metadata[:order]
  end

  def operational?
    return @metadata[:status] == "active" && @cluster != nil
  end

  def to_h
    hsh = {}
    hsh[:metadata] = @metadata.clone
    hsh[:metadata][:operational] = operational?
    hsh[:form] = @form.clone
    hsh[:form][:cluster] = @cluster
    hsh[:view] = @view.clone
    return hsh
  end

  def <=> (other)
    return 0 if !order && !other.order
    return 1 if !order
    return -1 if !other.order
    order <=> other.order
  end

  private
  def self.read_yaml(path:)
    contents = path.read
    YAML.safe_load(contents).to_h.deep_symbolize_keys
  end

  def self.parse_launcher_file(launcher_file:)
    file_config = read_yaml(path: launcher_file)
    #SUPPORT FOR SINGLE LAUNCHER CONFIG PER FILE OR AS AN ARRAY UNDER launchers:
    launchers_config_array = file_config.fetch(:launchers, [file_config])
    launchers_config_array.each_with_object([]) do |launcher_config, result|
      metadata = { type: "external" }
      metadata[:path] = launcher_file.to_s

      result << LauncherButton.new(metadata, launcher_config)
    end
    rescue => e
      Rails.logger.error("Can't parse launcher from:#{launcher_file} because of error: #{e}")
      return []
  end

  def set_cluster
    ood_app = BatchConnect::App.from_token @form[:token]
    @cluster = ood_app.clusters.first.id.to_s if ood_app.clusters.any?
  end

end