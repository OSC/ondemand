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
        'pun'   => NginxStage::PunConfigGenerator,
        'app'   => NginxStage::AppConfigGenerator,
        'nginx' => NginxStage::NginxProcessGenerator,
      }
    end

    # Starts the NginxStage workflow
    # @return [void]
    def self.start
      command = ARGV.first[0] != '-' ? ARGV.shift : nil

      generator = commands.fetch(command) do
        command ? raise(InvalidCommand, "invalid command: #{command}") : nil
      end

      parser = generator ? cmd_parser(command, generator) : default_parser
      parser.parse!( ARGV )

      puts generator.new(options).invoke if generator
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
        commands.each do |cmd, klass|
          opts.separator " #{cmd}\t\t# #{klass.desc}"
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
          args = v[:opt_args].respond_to?(:call) ? v[:opt_args].call : v[:opt_args]
          opts.on(*args) do |input|
            options[k] = sanitize input
          end
        end

        opts.separator ""
        opts.separator "General options:"
        generator.options.select {|k,v| !v[:required]}.each do |k, v|
          args = v[:opt_args].respond_to?(:call) ? v[:opt_args].call : v[:opt_args]
          opts.on(*args) do |input|
            options[k] = sanitize input
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
      # Sanitizes any bad characters received by user input
      # only accepts: a-z, A-Z, 0-9, _, -, /, ., ?, =, $
      def self.sanitize(input)
        if input.respond_to?(:gsub)
          input.gsub(/[^\w\/.?=$-]/, '')
        else
          input
        end
      end
  end
end
