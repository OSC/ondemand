require 'optparse'

module NginxStage
  # The command line interface for NginxStage
  module Application
    # Options parsed from CLI
    # @return [Hash] hash of options and their values
    def self.options
      @options ||= {}
    end

    # Available commands for the CLI
    # @return [Hash] hash of commands and their attributes
    def self.commands
      {
        'pun' => {
          handler: NginxStage::PunConfigGenerator,
          desc: 'Generate a new per-user nginx config and process',
          parser: pun_parser
        },
        'app' => {
          handler: NginxStage::AppConfigGenerator,
          desc: 'Generate a new nginx app config and reload process',
          parser: app_parser
        },
        'nginx' => {
          handler: NginxStage::NginxProcessGenerator,
          desc: 'Generate/control a per-user nginx process',
          parser: nginx_parser
        }
      }
    end

    # Starts the NginxStage workflow
    # @return [void]
    def self.start
      command = ARGV.first[0] != '-' ? ARGV.shift : nil

      cmd_hash = commands.fetch(command) do
        raise InvalidCommand, "invalid command: #{command}" if command
        {}
      end
      handler = cmd_hash[:handler]
      parser  = cmd_hash[:parser] || default_parser

      parser.parse!( ARGV )
      puts handler.new(options).invoke if handler
    rescue
      $stderr.puts "#{$!.to_s}"
      $stderr.puts "Run 'nginx_stage --help' to see a full list of available command line options."
      exit(false)
    end

    # Parses user-supplied arguments
    # @return [OptionParser] the option parser object
    def self.default_parser
      OptionParser.new do |opts|
        opts.banner = "Usage: nginx_stage COMMAND [OPTIONS]"

        opts.separator ""
        opts.separator "Commands:"
        commands.each {|k, v| opts.separator " #{k}\t\t# #{v[:desc]}"}

        opts.separator ""
        opts.separator "General options:"
        opts.on("-h", "--help", "# Show this help message") do
          puts opts
          exit
        end
        opts.on("-v", "--version", "# Show version") do
          puts "nginx_stage, version #{VERSION}"
          exit
        end

        opts.separator ""
        opts.separator "All commands can be run with -h (or --help) for more information."
        opts.separator ""
      end
    end

    # Parses user-supplied arguments for the pun command
    # @return [OptionParser] the option parser object
    def self.pun_parser
      OptionParser.new do |opts|
        opts.banner = "Usage: nginx_stage pun [OPTIONS]"

        opts.separator ""
        opts.separator "Required options:"
        opts.on("-u", "--user=USER", "# The USER of the per-user nginx process") do |user|
          options[:user] = User.new(sanitize user)
        end

        opts.separator ""
        opts.separator "General options:"
        opts.on("-a", "--app-init-uri=APP_INIT_URI", "# The user is redirected to the APP_INIT_URI if app doesn't exist", "# Default: ''") do |app_init|
          options[:app_init_uri] = sanitize app_init
        end
        opts.on("-N", "--[no-]skip-nginx", "# Skip execution of the per-user nginx process", "# Default: false") do |nginx|
          options[:skip_nginx] = nginx
        end

        opts.separator ""
        opts.separator "Common options:"
        opts.on("-h", "--help", "# Show this help message") do
          puts opts
          exit
        end
        opts.on("-v", "--version", "# Show version") do
          puts "nginx_stage, version #{VERSION}"
        end

        opts.separator ""
        opts.separator <<-EOF.gsub(/^ {8}/, '')
        Examples:
            To generate a per-user nginx environment & launch nginx:

                nginx_stage pun --user=bob --app-init-uri='/nginx/init?redir=$http_x_forwarded_escaped_uri'

            this will add a URI redirect if the user accesses an app that doesn't exist.

            To generate ONLY the per-user nginx environment:

                nginx_stage pun --user=bob --skip-nginx

            this will return the per-user nginx config path and won't run nginx. In addition
            it will remove the URI redirect from the config unless we specify `--app-init-uri`.
        EOF
        opts.separator ""
      end
    end

    # Parses user-supplied arguments for the app command
    # @return [OptionParser] the option parser object
    def self.app_parser
      OptionParser.new do |opts|
        opts.banner = "Usage: nginx_stage app [OPTIONS]"

        opts.separator ""
        opts.separator "Required options:"
        opts.on("-u", "--user=USER", "# The USER of the per-user nginx process") do |user|
          options[:user] = User.new(sanitize user)
        end
        opts.on("-r", "--sub-request=SUB_REQUEST", "# The SUB_REQUEST that requests the specified app") do |request|
          options[:sub_request] = sanitize request
        end

        opts.separator ""
        opts.separator "General options:"
        opts.on("-i", "--sub-uri=SUB_URI", "# The SUB_URI that requests the per-user nginx", "# Default: ''") do |uri|
          options[:sub_uri] = sanitize uri
        end
        opts.on("-N", "--[no-]skip-nginx", "# Skip execution of the per-user nginx process", "# Default: false") do |nginx|
          options[:skip_nginx] = nginx
        end

        opts.separator ""
        opts.separator "Common options:"
        opts.on("-h", "--help", "# Show this help message") do
          puts opts
          exit
        end
        opts.on("-v", "--version", "# Show version") do
          puts "nginx_stage, version #{VERSION}"
        end

        opts.separator ""
        opts.separator <<-EOF.gsub(/^ {8}/, '')
        Examples:
            To generate an app config from a URI request and reload the nginx
            process:

                nginx_stage app --user=bob --sub-uri=/pun --sub-request=/shared/jimmy/fillsim/container/13

            To generate ONLY the app config from a URI request:

                nginx_stage app --user=bob --sub-uri=/pun --sub-request=/shared/jimmy/fillsim --skip-nginx

            this will return the app config path and won't run nginx.
        EOF
        opts.separator ""
      end
    end

    # Parses user-supplied arguments for the nginx command
    # @return [OptionParser] the option parser object
    def self.nginx_parser
      OptionParser.new do |opts|
        opts.banner = "Usage: nginx_stage nginx [OPTIONS]"

        opts.separator ""
        opts.separator "Required options:"
        opts.on("-u", "--user=USER", "# The USER of the per-user nginx process") do |user|
          options[:user] = User.new(sanitize user)
        end

        opts.separator ""
        opts.separator "General options:"
        opts.on("-s", "--signal=SIGNAL", NginxStage.nginx_signals, "# Send SIGNAL to per-user nginx process: #{NginxStage.nginx_signals.join('/')}", "# Default: none") do |signal|
          options[:signal] = signal
        end
        opts.on("-N", "--[no-]skip-nginx", "# Skip execution of the per-user nginx process", "# Default: false") do |nginx|
          options[:skip_nginx] = nginx
        end
        opts.on("-h", "--help", "# Show this help message") do
          puts opts
          exit
        end

        opts.separator ""
        opts.separator "Common options:"
        opts.on("-h", "--help", "# Show this help message") do
          puts opts
          exit
        end
        opts.on("-v", "--version", "# Show version") do
          puts "nginx_stage, version #{VERSION}"
        end

        opts.separator ""
        opts.separator <<-EOF.gsub(/^ {8}/, '')
        Examples:
            To stop Bob's nginx process:

                nginx_stage nginx --user=bob --signal=stop

            which sends a `stop` signal to Bob's per-user NGINX process.

            If `--skip-nginx` is supplied it returns the system-level command
            that would have been called.
        EOF
        opts.separator ""
      end
    end


    private
      # Sanitizes any bad characters received by user input
      # only accepts: a-z, A-Z, 0-9, _, -, /, ., ?, =, $
      def self.sanitize(string)
        string.gsub(/[^\w\/.?=$-]/, '')
      end
  end
end
