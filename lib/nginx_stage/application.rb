require 'optparse'

module NginxStage
  # The command line interface for NginxStage
  module Application
    # Starts the NginxStage workflow
    # @return [void]
    def self.start
      options = parse!( ARGV )
      command = ARGV.first

      raise MissingCommand, "missing command" unless command

      case command
      when "pun"
        puts NginxStage::PunConfigGenerator.new(options).invoke
      when "app"
        puts NginxStage::AppConfigGenerator.new(options).invoke
      when "nginx"
        puts NginxStage::NginxProcessGenerator.new(options).invoke
      else
        raise InvalidCommand, "invalid command: #{command}"
      end
    rescue
      $stderr.puts "#{$!.to_s}"
      $stderr.puts "Run 'nginx_stage --help' to see a full list of available command line options."
      exit(false)
    end

    # Parses user-supplied arguments
    # @param args [Array<String>] the array of arguments to parse
    # @return [OptionParser] the option parser object
    def self.parse!(args)
      options = {}

      @opts = OptionParser.new do |opts|
        opts.banner = <<-EOF.gsub(/^ {8}/, '')
        Usage: nginx_stage COMMAND --user=USER [OPTIONS]

        Commands:
         pun      # Generate a new per-user nginx config and process
         app      # Generate a new nginx app config and reload process
         nginx    # Generate/control a per-user nginx process
        EOF

        opts.separator ""
        opts.separator "Required options:"
        opts.on("-u", "--user=USER", "# The USER running the per-user nginx process") do |user|
          options[:user] = clean_up user
        end

        opts.separator ""
        opts.separator "Pun options:"
        opts.on("-a", "--app-init-uri=APP_INIT_URI", "# The APP_INIT_URI user is redirected to if app doesn't exist") do |app_init|
          options[:app_init_uri] = clean_up app_init
        end

        opts.separator ""
        opts.separator "App options:"
        opts.on("-i", "--sub-uri=SUB_URI", "# The SUB_URI that requests the per-user nginx") do |uri|
          options[:sub_uri] = clean_up uri
        end
        opts.on("-r", "--sub-request=SUB_REQUEST", "# The SUB_REQUEST that requests the specified app") do |request|
          options[:sub_request] = clean_up request
        end

        opts.separator ""
        opts.separator "Nginx options:"
        opts.on("-s", "--signal=SIGNAL", NginxStage.nginx_signals, "# Send SIGNAL to per-user nginx process: #{NginxStage.nginx_signals.join('/')}") do |signal|
          options[:signal] = signal
        end

        opts.separator ""
        opts.separator "Common options:"
        opts.on("-N", "--[no-]skip-nginx", "# Skip execution of the per-user nginx process") do |nginx|
          options[:skip_nginx] = nginx
        end
        opts.on("-h", "--help", "# Show this help message") do
          puts help
          exit
        end
        opts.on("-v", "--version", "# Show version") do
          puts "nginx_stage, version #{VERSION}"
          exit
        end

        opts.separator ""
        opts.separator "Examples:"
        opts.separator "    To generate a per-user nginx environment & launch nginx:"
        opts.separator ""
        opts.separator "        `nginx_stage pun --user=bob --app-init-uri='/nginx/init?redir=$http_x_forwarded_escaped_uri'`"
        opts.separator ""
        opts.separator "    this will add a URI redirect if the user accesses an app that doesn't exist."
        opts.separator ""
        opts.separator "    To generate ONLY the per-user nginx environment:"
        opts.separator ""
        opts.separator "        `nginx_stage pun --user=bob --skip-nginx`"
        opts.separator ""
        opts.separator "    this will return the per-user nginx config path and won't run nginx. In addition"
        opts.separator "    it will remove the URI redirect from the config unless we specify `--app-init-uri`."
        opts.separator ""
        opts.separator "    To stop the above nginx process:"
        opts.separator ""
        opts.separator "        `nginx_stage nginx --user=bob --signal=stop`"
        opts.separator ""
        opts.separator "    this is equivalent to sending `nginx -c USER_CONFIG -s SIGNAL`"
        opts.separator ""
        opts.separator "    To generate an app config from a URI request and reload the nginx process:"
        opts.separator ""
        opts.separator "        `nginx_stage app --user=bob --sub-uri=/pun --sub-request=/shared/jimmy/fillsim/container/13`"
        opts.separator ""
        opts.separator "    To generate ONLY the app config from a URI request:"
        opts.separator ""
        opts.separator "        `nginx_stage app --user=bob --sub-uri=/pun --sub-request=/shared/jimmy/fillsim --skip-nginx`"
        opts.separator ""
        opts.separator "    this will return the app config path and won't run nginx."
        opts.separator ""
      end

      @opts.parse!(args)

      options
    end

    # Generates the help message
    # @return [String] the help message
    def self.help
      @opts
    end


    private
      # Cleans up any bad characters received by user input
      # only accepts: a-z, A-Z, 0-9, _, -, /, ., ?, =, $
      def self.clean_up(string)
        string.gsub(/[^\w\/.?=$-]/, '')
      end
  end
end
