class Manifest
  attr_accessor :name, :path, :host, :notes, :script

  # @param [Pathname] path Pathname object pointing to manifest file
  def self.load(path)
    if path.file?
      Manifest.new(path, YAML.load_file(path.to_s))
    else
      Manifest.new(path, {})
    end
  rescue Exception => e
    InvalidManifest.new(e)
  end

  class InvalidContentError < ArgumentError; end

  # Constructor
  # @param [Pathname] path A Pathname object representing the manifest location
  # @param [Hash] opts The options associated with the manifest
  # @option opts [String] "name" The name of the templated workflow
  # @option opts [String] "host" The name of the compute host that the job has been optimized for
  # @option opts [String] "notes" Notes associated with the templated workflow
  # @oprion opts [String] "script" The relative path of the submit script in the templated workflow
  def initialize(path, opts)
    raise InvalidContentError.new("Invalid Content in manifest.yml") unless(opts && opts.is_a?(Hash))

    @path = Pathname.new(path)

    @name = opts.fetch("name", default_name)
    @host = opts.fetch("host", default_host)
    @notes = opts.fetch("notes", default_notes)

    if Configuration.render_template_notes_as_markdown?
      begin
        @notes = OodAppkit.markdown.render(@notes)
      rescue StandardError => e
        Rails.logger.warn "Markdown rendering failed for manifest #{@path.to_s}"
      end
    end

    @script = opts.fetch("script", default_script)
  end

  def script_path
    # manifest path includes the manifest.yml so use dirname
    script ? path.dirname.join(script).to_s : ""
  end

  # all based on path
  def default_name
    path.dirname.basename.to_s
  end

  def default_host
    OODClusters.first ? OODClusters.first.id.to_s : ""
  end

  def default_notes
    return "Change these notes by editing the manifest.yml in this template's directory"
  end

  # Grab the first file name ending in .pbs or .sh
  def default_script
    (Dir.entries(path.dirname).select{ |f| f =~ /\.pbs$/i  }.first || Dir.entries(path.dirname).select{ |f| f =~ /\.sh$/i  }.first) if path.dirname.directory?
  end
end

class InvalidManifest < Manifest
  attr_reader :exception

  def initialize(exception)
    super("", { "name" => "Invalid Manifest", "notes" => exception})

    @exception = exception
  end
end
