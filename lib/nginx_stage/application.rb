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

        commands:
         pun    Generate a new per-user nginx config and process
         app    Generate a new nginx app config and reload process
        EOF

        opts.separator ""
        opts.separator "required options:"
        opts.on("-u", "--user=USER", "# The USER running the per-user nginx process") do |user|
          options[:user] = user
        end

        opts.separator ""
        opts.separator "pun options:"
        opts.on("-s", "--signal=SIGNAL", NginxStage.nginx_signals, "# Send SIGNAL to per-user nginx process: #{NginxStage.nginx_signals.join('/')}") do |signal|
          options[:signal] = signal
        end

        opts.separator ""
        opts.separator "app options:"
        opts.on("-r", "--request=REQUEST", "# The REQUEST uri accessed") do |request|
          options[:request] = request
        end

        opts.separator ""
        opts.separator "common options:"
        opts.on("-N", "--[no-]skip-nginx", "# Skip executing the per-user nginx process") do |nginx|
          options[:skip_nginx] = nginx
        end
        opts.on_tail("-h", "--help", "# Show this help message") do
          puts help
          exit
        end
        opts.on_tail("-v", "--version", "# Show version") do
          puts "nginx_stage, version #{VERSION}"
          exit
        end
      end

      @opts.parse!(args)

      options
    end

    def self.help
      @opts
    end
  end
end
