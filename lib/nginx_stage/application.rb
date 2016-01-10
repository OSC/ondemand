require 'optparse'

module NginxStage
  module Application
    def self.start
      options = parse!( ARGV )
      command = ARGV.first

      raise MissingCommand, "missing command" unless command

      case command
      when "pun"
        puts NginxStage::GeneratePunConfig.new(options).invoke
      when "app"
        puts NginxStage::GenerateAppConfig.new(options).invoke
      else
        raise InvalidCommand, "invalid command: #{command}"
      end
    rescue
      $stderr.puts "#{$!.to_s}"
      $stderr.puts "Run 'nginx_stage --help' to see a full list of available command line options."
      exit(false)
    end

    def self.parse!(args)
      options = {}

      @opts = OptionParser.new do |opts|
        opts.banner = <<-EOF.gsub(/^ {8}/, '')
        Usage: nginx_stage COMMAND --user=USER [OPTIONS]

        Commands:
         pun      # Generate a new per-user nginx config and process
         app      # Generate a new nginx app config and reload process
        EOF

        opts.separator ""
        opts.separator "Required options:"
        opts.on("-u", "--user=USER", "# The USER running the per-user nginx process") do |user|
          options[:user] = user
        end

        opts.separator ""
        opts.separator "Pun options:"
        opts.on("-s", "--signal=SIGNAL", NginxStage.nginx_signals, "# Send SIGNAL to per-user nginx process: #{NginxStage.nginx_signals.join('/')}") do |signal|
          options[:signal] = signal
        end

        opts.separator ""
        opts.separator "App options:"
        opts.on("-i", "--sub-uri=SUB_URI", "# The SUB_URI that requests the per-user nginx") do |uri|
          options[:sub_uri] = uri
        end
        opts.on("-r", "--sub-request=SUB_REQUEST", "# The SUB_REQUEST that requests the specified app") do |request|
          options[:sub_request] = request
        end

        opts.separator ""
        opts.separator "Common options:"
        opts.on("-N", "--[no-]skip-nginx", "# Skip executing the per-user nginx process") do |nginx|
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
        opts.separator "        `nginx_stage pun --user=bob`"
        opts.separator ""
        opts.separator "    To stop the above nginx process:"
        opts.separator ""
        opts.separator "        `nginx_stage pun --user=bob --signal=stop`"
        opts.separator ""
        opts.separator "    To generate ONLY the per-user nginx environment:"
        opts.separator ""
        opts.separator "        `nginx_stage pun --user=bob --skip-nginx`"
        opts.separator ""
        opts.separator "    To generate an app config from a URI request and reload the nginx process:"
        opts.separator ""
        opts.separator "        `nginx_stage app --user=bob --sub-uri=/pun --sub-request=/shared/jimmy/fillsim/container/13`"
        opts.separator ""
        opts.separator "    To generate ONLY the app config from a URI request:"
        opts.separator ""
        opts.separator "        `nginx_stage app --user=bob --sub-uri=/pun --sub-request=/shared/jimmy/fillsim --skip-nginx`"
        opts.separator ""
      end

      @opts.parse!(args)

      options
    end

    def self.help
      @opts
    end
  end
end
