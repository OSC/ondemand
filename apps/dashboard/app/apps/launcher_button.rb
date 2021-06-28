class LauncherButton
  VALID_ID_CHARACTERS = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a + %w[_ -]

  def self.launchers
    app_launchers = ::Configuration.launchers.map{ |system_launcher| LauncherButton.new({ type: "system" }, system_launcher) }

    #order by order field. Items without order field will go last.
    app_launchers.compact.sort
  end

  def initialize(metadata, config)
    @metadata = metadata
    @form = config[:form] || {}
    @view = config[:view] || {}

    @metadata[:id] = config[:id]&.downcase

    raise ArgumentError, "launch button config must defined an id metadata=#{metadata}" unless @metadata[:id]
    raise ArgumentError, "launch button config must defined a valid id id=#{@metadata[:id]}" unless valid_id?
    raise ArgumentError, "launch button config must defined a token field id=#{@metadata[:id]} metadata=#{metadata}" unless @form[:token]


    @metadata[:order] = config[:order]
    @metadata[:status] = config[:status] ? config[:status].downcase : "active"

    ood_app = BatchConnect::App.from_token @form[:token]
    @cluster = ood_app.clusters.first.id.to_s if ood_app.clusters.any?
    @view[:default_logo] = ood_app.link.icon_uri
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
  def valid_id?
    id.chars.all? { |ch| VALID_ID_CHARACTERS.include?(ch) }
  end

end