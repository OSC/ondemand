require "digest"
require "fileutils"
require "optparse"
require "tempfile"
require "time"
require "yaml"

module OodPortalGenerator
  # The command line interface for OodPortalGenerator
  module Application
    class << self
      # The yaml configuration file used as context for template
      # @return [Pathname] path to yaml config
      def config
        Pathname.new(@config || ENV['CONFIG'] || "/etc/ood/config/ood_portal.yml")
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

      def rpm
        @rpm.nil? ? false : @rpm
      end

      def force
        @force.nil? ? false : @force
      end

      def detailed_exitcodes
        @detailed_exitcodes.nil? ? false : @detailed_exitcodes
      end

      def change_exit
        detailed_exitcodes ? 3 : 0
      end

      def skip_exit
        detailed_exitcodes ? 4 : 0
      end

      def apache
        ENV['APACHE'] || (OodPortalGenerator.scl_apache? ? '/opt/rh/httpd24/root/etc/httpd/conf.d/ood-portal.conf' : '/etc/httpd/conf.d/ood-portal.conf')
      end

      def apache_bak
        "#{apache}.#{Time.now.strftime('%Y%m%dT%H%M%S')}"
      end

      def apache_services
        if OodPortalGenerator.scl_apache?
          ['httpd24-httpd', 'httpd24-htcacheclean']
        else
          ['httpd', 'htcacheclean']
        end
      end

      def sum_path
        ENV['SUM'] || '/etc/ood/config/ood_portal.sha256sum'
      end

      # return string contents of file without comments
      def read_file_omitting_comments(input)
        return '' unless File.exist?(input)
        File.readlines(input).reject {|line| line =~ /^\s*#/ }.join('')
      end

      def checksum(input)
        Digest::SHA256.hexdigest(read_file_omitting_comments(input))
      end

      def save_checksum(input)
        File.write(sum_path, "#{checksum(input)} #{apache}\n")
      end

      def checksum_matches?(input)
        checksum_str = File.readlines(sum_path)[0]
        checksum = checksum_str.split(' ')[0]

        str = read_file_omitting_comments(input)
        new_checksum = checksum(input)

        checksum == new_checksum
      end

      def checksum_exists?
        return false unless File.exist?(sum_path)
        File.readlines(sum_path).grep(apache).size == 0
      end

      def update_replace?
        # If checksum of ood-portal.conf matches or ood-portal.conf doesn't exit, replace is possible.
        # If the checksum matches this means a site has not changed ood-portal.conf outside ood-portal-generator
        if ! File.exist?(apache)
          replace = true
        elsif checksum_matches?(apache)
          replace = true
        else
          replace = false
        end
        replace = true if force
        return replace
      end

      def files_identical?(a, b)
        `cmp -s "#{a}" "#{b}" 1>/dev/null 2>&1`
        $?.success?
      end

      def exit!(code)
        case code
        when TrueClass
          exit(0)
        when FalseClass
          exit(1)
        else
          exit(code)
        end
      end

      def generate()
        view = View.new(context)
        rendered_template = view.render(template.read)
        output.write(rendered_template)
      end

      def update_ood_portal()
        ret = 0
        changed = false
        new_apache = Tempfile.new('new_apache')
        @output = new_apache.path
        generate()

        # Create checksum file if the path to ood-portal.conf not in checksum file
        # Checksum is based on mktemp generated ood-portal.conf but using path of real ood-portal.conf
        if ! checksum_exists?
          puts "Generating Apache config checksum file: '#{sum_path}'"
          save_checksum(new_apache.path)
        end

        replace = update_replace?

        if ! files_identical?(new_apache.path, apache)
          if replace
            if File.exist?(apache)
              puts "Backing up previous Apache config to: '#{apache_bak}'"
              FileUtils.mv(apache, apache_bak)
            end
            puts "Generating new Apache config at: '#{apache}'"
            `cat "#{new_apache.path}" > "#{apache}"`
            puts "Generating Apache config checksum file: '#{sum_path}'"
            save_checksum(apache)
            ret = change_exit
            changed = true
          else
            puts "WARNING: Checksum of #{apache} does not match previous value, not replacing."
            puts "Generating new Apache config at: '#{apache}.new'"
            `cat "#{new_apache.path}" > "#{apache}.new"`
            ret = skip_exit
          end
        else
          puts "No change in Apache config."
        end

        new_apache.unlink

        if rpm || ! replace
          return ret
        end

        puts "Completed successfully!"
        if changed
          puts ""
          puts "Restart the #{apache_services[0]} service now."
          puts ""
          puts "Suggested command:"
          puts "    sudo systemctl try-restart #{apache_services[0]}.service #{apache_services[1]}.service"
          puts ""
        end

        return ret
      end

      # Starts the OodPortalGenerator CLI
      # @return [void]
      def start(mode, argv = ARGV)
        # Set a cleaner process title
        Process.setproctitle("#{mode} #{argv.join(" ")}")

        # Parse CLI arguments
        OptionParser.new do |parser|
          parser.banner = "Usage: #{mode} [options]"

          if mode == 'generate'
            add_generate_opt_parser_attrs(parser)
            default = "-c #{config} -t #{template}"
          elsif mode == 'update_ood_portal'
            add_generate_opt_parser_attrs(parser, false)
            add_update_opt_parser_attrs(parser)
            default = ""
          end

          add_shared_opt_parser_attrs(parser)

          parser.separator ""
          parser.separator "Default:"
          parser.separator "  #{mode} #{default}"
        end.parse!(argv)

        # Render Apache portal config
        if mode == 'generate'
          generate()
        elsif mode == 'update_ood_portal'
          exitcode = update_ood_portal()
          exit!(exitcode)
        end
      rescue
        $stderr.puts "#{$!.to_s}"
        $stderr.puts "Run '#{mode} --help' to see a full list of available options."
        exit!(false)
      end

      def add_generate_opt_parser_attrs(parser, output = true)
        parser.on("-c", "--config CONFIG", String, "YAML config file used to render template") do |v|
          @config = v
        end

        parser.on("-t", "--template TEMPLATE", String, "ERB template that is rendered") do |v|
          @template = v
        end

        if output
          parser.on("-o", "--output OUTPUT", String, "File that rendered template is output to") do |v|
            @output = v
          end
        end
      end

      def add_update_opt_parser_attrs(parser)
        parser.on("-r", "--rpm", TrueClass, "Execution performed during RPM install") do |v|
          @rpm = v
        end

        parser.on("-f", "--force", TrueClass, "Force replacement of configs even if checksums differ") do |v|
          @force = v
        end

        parser.on("--detailed-exitcodes", TrueClass, "Exit with 3 when changes are made and 4 when changes skipped") do |v|
          @detailed_exitcodes = v
        end
      end

      def add_shared_opt_parser_attrs(parser)
        parser.on("-v", "--version", "Print current version") do
          puts "version #{OodPortalGenerator::VERSION}"
          exit
        end

        parser.on("-h", "--help", "Show this help message") do
          puts parser
          exit
        end
      end
    end
  end
end
