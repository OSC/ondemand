require 'optparse'
require 'cgi'

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
        'pun'         => NginxStage::PunConfigGenerator,
        'app'         => NginxStage::AppConfigGenerator,
        'app_reset'   => NginxStage::AppResetGenerator,
        'app_list'    => NginxStage::AppListGenerator,
        'app_clean'   => NginxStage::AppCleanGenerator,
        'nginx'       => NginxStage::NginxProcessGenerator,
        'nginx_show'  => NginxStage::NginxShowGenerator,
        'nginx_list'  => NginxStage::NginxListGenerator,
        'nginx_clean' => NginxStage::NginxCleanGenerator,
      }
    end

    # Starts the NginxStage workflow
    # @return [void]
    def self.start
      ARGV << "--help" if ARGV.empty?
      command = ARGV.first[0] != '-' ? ARGV.shift : nil

      generator = commands.fetch(command) do
        command ? raise(InvalidCommand, "invalid command: #{command}") : nil
      end

      parser = generator ? cmd_parser(command, generator) : default_parser
      parser.parse!( ARGV )
      generator.new(options).invoke if generator
    rescue
      $stderr.puts "#{$!.to_s}"
      unless NginxStage.disable_nginx_stage_help_message
        $stderr.puts "Run 'nginx_stage --help' to see a full list of available command line options."
      end
      exit(false)
    end

    # Parses user-supplied arguments
    # @return [OptionParser] the option parser object
    def self.default_parser
      OptionParser.new do |opts|
        opts.banner = "Usage: nginx_stage COMMAND [OPTIONS]"

        opts.separator ""
        opts.separator "Commands:"
        commands.each do |cmd, klass|
          opts.separator sprintf(" %-20s# %s", cmd, klass.desc)
        end

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

    # Parses user-supplied arguments for a given command
    # @param command [String] the name of the given command
    # @param generator [Generator] a generator class for a given command
    # @return [OptionParser] the option parser object
    def self.cmd_parser(command, generator)
      OptionParser.new do |opts|
        opts.banner = "Usage: nginx_stage #{command} [OPTIONS]"

        opts.separator ""
        opts.separator "Required options:"
        generator.options.select {|k,v| v[:required]}.each do |k, v|
          opts.on(*v[:opt_args]) do |input|
            options[k] = unescape(input)
          end
        end

        opts.separator ""
        opts.separator "General options:"
        generator.options.select {|k,v| !v[:required]}.each do |k, v|
          opts.on(*v[:opt_args]) do |input|
            options[k] = unescape(input)
          end
        end

        opts.separator ""
        opts.separator "Common options:"
        opts.on("-h", "--help", "# Show this help message") do
          puts opts
          exit
        end
        opts.on("-v", "--version", "# Show version") do
          puts "nginx_stage, version #{VERSION}"
          exit
        end

        opts.separator ""
        opts.separator generator.footer
        opts.separator ""
      end
    end


    private
      # Unescape string
      def self.unescape(value)
        value.respond_to?(:gsub) ? CGI::unescape(value) : value
      end
  end
end
