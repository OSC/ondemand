class Manifest
  attr_reader :name, :path, :host, :notes, :script

  # path - Pathname object to manifest file
  def self.load(path)
    if path.file?
      Manifest.new(path, YAML.load_file(path.to_s))
    else
      Manifest.new(path, {})
    end
  rescue Exception => e
    InvalidManifest.new(e)
  end

  def initialize(path, opts)
    raise InvalidContentError.new unless(opts && opts.is_a?(Hash))

    @path = path

    @name = opts.fetch("name", default_name)
    @host = opts.fetch("host", default_host)
    @notes = opts.fetch("notes", default_notes)
    @script = opts.fetch("script", default_script)
  end

  def script_path
    Pathname.new(path).join(script).to_s
  end

  # all based on path
  def default_name
    Pathname.new(path).dirname.basename.to_s
  end

  def default_host
    Servers.first[0]
  end

  def default_notes
    path
  end

  # Grab the first file name ending in .sh
  def default_script
    Dir.entries(path).select{ |f| f =~ /\.sh$/i  }.first if Pathname.new(path).directory?
  end
end


class InvalidManifest < Manifest
  attr_reader :exception

  def initialize(exception)
    super("", {name: "InvalidManifest", notes: exception.message })

    @exception = exception
  end
end
