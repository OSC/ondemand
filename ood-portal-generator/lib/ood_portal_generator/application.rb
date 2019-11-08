require "optparse"
require "yaml"

module OodPortalGenerator
  # The command line interface for OodPortalGenerator
  module Application
    class << self
      # The yaml configuration file used as context for template
      # @return [Pathname] path to yaml config
      def config
        Pathname.new(@config || "/etc/ood/config/ood_portal.yml")
      end

      # The erb template file that will be rendered
      # @return [Pathname] path to erb template
      def template
        Pathname.new(@template || OodPortalGenerator.root.join("templates", "ood-portal.conf.erb"))
      end

      # The io object that the rendered template will be written to
      # @return [Pathname, IO] io object where rendered output is written to
      def output
        @output ? Pathname.new(@output) : $stdout
      end

      # The context used to render the template
      # @return [Hash] context hash
      def context
        config.file? ? YAML.load_file(config) : {}
      end

      # Starts the OodPortalGenerator CLI
      # @return [void]
      def start(mode)
        # Set a cleaner process title
        Process.setproctitle("#{mode} #{ARGV.join(" ")}")

        # Parse CLI arguments
        parser.parse!

        # Render Apache portal config
        if mode == 'generate'
          view = View.new(context)
          rendered_template = view.render(template.read)
          output.write(rendered_template)
        end
      rescue
        $stderr.puts "#{$!.to_s}"
        $stderr.puts "Run '#{mode} --help' to see a full list of available options."
        exit(false)
      end

      # Parser used for parsing CLI options
      # @return [OptionParser] the option parser object
      def parser
        OptionParser.new do |parser|
          parser.banner = "Usage: generate [options]"

          parser.on("-c", "--config CONFIG", String, "YAML config file used to render template") do |v|
            @config = v
          end

          parser.on("-t", "--template TEMPLATE", String, "ERB template that is rendered") do |v|
            @template = v
          end

          parser.on("-o", "--output OUTPUT", String, "File that rendered template is output to") do |v|
            @output = v
          end

          parser.on("-v", "--version", "Print current version") do
            puts "version #{OodPortalGenerator::VERSION}"
            exit
          end

          parser.on("-h", "--help", "Show this help message") do
            puts parser
            exit
          end

          parser.separator ""
          parser.separator "Default:"
          parser.separator "  generate -c #{config} -t #{template}"
        end
      end
    end
  end
end
