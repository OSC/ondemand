# frozen_string_literal: true

require 'English'
require 'English'
require 'digest'
require 'fileutils'
require 'optparse'
require 'tempfile'
require 'time'
require 'yaml'

module OodPortalGenerator
  # The command line interface for OodPortalGenerator
  module Application
    class << self
      # The yaml configuration file used as context for template
      # @return [Pathname] path to yaml config
      def config
        Pathname.new(@config || ENV['CONFIG'] || '/etc/ood/config/ood_portal.yml')
      end

      # The erb template file that will be rendered
      # @return [Pathname] path to erb template
      def template
        Pathname.new(@template || OodPortalGenerator.root.join('templates', 'ood-portal.conf.erb'))
      end

      def no_auth_template
        Pathname.new(OodPortalGenerator.root.join('templates', 'no-auth.conf.erb'))
      end

      # The io object that the rendered template will be written to
      # @return [Pathname, IO] io object where rendered output is written to
      def output
        @output ? Pathname.new(@output) : $stdout
      end

      # The io object that rendered dex config will be written to
      # @return [Pathname, IO] io object where rendered config is written to
      def dex_output
        @dex_output ? Pathname.new(@dex_output) : $stderr
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

      def insecure
        @insecure.nil? ? false : @insecure
      end

      def prefix
        ENV['DESTDIR'] || ENV['PREFIX'] || ''
      end

      def apache
        return ENV['APACHE'] unless ENV['APACHE'].nil?

        path = if OodPortalGenerator.debian?
                 '/etc/apache2/sites-available/ood-portal.conf'
               else
                 '/etc/httpd/conf.d/ood-portal.conf'
               end
        File.join(prefix, path)
      end

      def apache_bak
        "#{apache}.#{Time.now.strftime('%Y%m%dT%H%M%S')}"
      end

      def apache_services
        if OodPortalGenerator.debian?
          ['apache2']
        else
          ['httpd']
        end
      end

      def sum_path
        ENV['SUM'] || File.join(prefix, '/etc/ood/config/ood_portal.sha256sum')
      end

      def dex_config
        ENV['DEX_CONFIG'] || File.join(prefix, '/etc/ood/dex/config.yaml')
      end

      def dex_config_bak
        @dex_config_bak ||= "#{dex_config}.#{Time.now.strftime('%Y%m%dT%H%M%S')}"
      end

      # return string contents of file without comments
      def read_file_omitting_comments(input)
        return '' unless File.exist?(input)

        File.readlines(input).reject { |line| line =~ /^\s*#/ }.join('')
      end

      def checksum(input)
        Digest::SHA256.hexdigest(read_file_omitting_comments(input))
      end

      def save_checksum(input)
        File.write(sum_path, "#{checksum(input)} #{apache}\n")
      end

      def checksum_matches?(input)
        return true unless checksum_exists?

        checksum_str = File.readlines(sum_path)[0]
        checksum = checksum_str.split(' ')[0]

        str = read_file_omitting_comments(input)
        new_checksum = checksum(input)

        checksum == new_checksum
      end

      def checksum_exists?
        return false unless File.exist?(sum_path)
        return false if File.zero?(sum_path)

        File.readlines(sum_path).grep(apache).size.zero?
      end

      def update_replace?
        # If checksum of ood-portal.conf matches or ood-portal.conf doesn't exit, replace is possible.
        # If the checksum matches this means a site has not changed ood-portal.conf outside ood-portal-generator
        force || !File.exist?(apache) || checksum_matches?(apache)
      end

      def files_identical?(a, b)
        `cmp -s "#{a}" "#{b}" 1>/dev/null 2>&1`
        $CHILD_STATUS.success?
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

      def apache_changed_output
        apache_units = apache_services.map { |a| "#{a}.service" }.join(' ')
        output = ['']
        output << "Restart the #{apache_services[0]} service now."
        output << ''
        output << 'Suggested command:'
        output << "    sudo systemctl try-restart #{apache_units}"
        output << ''
        output
      end

      def generate
        view = View.new(context)
        dex = Dex.new(context, view, insecure)
        dex_enabled = Dex.installed? && dex.enabled?

        # convienence defaults for folks who are using dex or OIDC
        view.auth = Dex.default_auth if dex_enabled && !view.auth?
        content = view.auth? ? view.render(template.read) : view.render(no_auth_template.read)

        output.write(content)
        dex_output.write(dex.render) if dex_enabled
      end

      def update_ood_portal
        ret = 0
        changed = false
        dex_changed = false
        new_apache = Tempfile.new('new_apache')
        @output = new_apache.path
        new_dex_config = Tempfile.new('dex_config')
        @dex_output = new_dex_config.path
        generate

        # Create checksum file if the path to ood-portal.conf not in checksum file
        # Checksum is based on mktemp generated ood-portal.conf but using path of real ood-portal.conf
        unless checksum_exists?
          puts "Generating Apache config checksum file: '#{sum_path}'"
          save_checksum(new_apache.path)
        end

        replace = update_replace?

        if !files_identical?(new_apache.path, apache)
          if replace
            if File.exist?(apache)
              puts "Backing up previous Apache config to: '#{apache_bak}'"
              FileUtils.mv(apache, apache_bak)
            end
            puts "Generating new Apache config at: '#{apache}'"
            `cat "#{new_apache.path}" > "#{apache}"`
            FileUtils.chown(OodPortalGenerator.chown_apache_user, OodPortalGenerator.apache_group, apache,
                            verbose: true)
            FileUtils.chmod(0o640, apache, verbose: true)
            puts "Generating Apache config checksum file: '#{sum_path}'"
            save_checksum(apache)
            ret = change_exit
            changed = true
          else
            apache_new = "#{apache}.new"
            puts "WARNING: Checksum of #{apache} does not match previous value, not replacing."
            puts "Generating new Apache config at: '#{apache_new}'"
            `cat "#{new_apache.path}" > "#{apache_new}"`
            FileUtils.chown(OodPortalGenerator.chown_apache_user, OodPortalGenerator.apache_group, apache_new,
                            verbose: true)
            FileUtils.chmod(0o640, apache_new, verbose: true)
            ret = skip_exit
          end
        else
          puts 'No change in Apache config.'
        end

        unless File.zero?(new_dex_config.path)
          if !files_identical?(new_dex_config.path, dex_config)
            dex_changed = true
            if File.exist?(dex_config)
              puts "Backing up previous Dex config to: '#{dex_config_bak}'"
              FileUtils.mv(dex_config, dex_config_bak, verbose: true)
            end
            puts "Generating new Dex config at: #{dex_config}"
            FileUtils.mv(new_dex_config.path, dex_config, verbose: true)
            FileUtils.chown(OodPortalGenerator.dex_user, OodPortalGenerator.dex_group, dex_config, verbose: true)
            FileUtils.chmod(0o600, dex_config, verbose: true)
          else
            puts 'No change in the Dex config.'
          end
        end

        new_apache.unlink

        return ret if rpm || !replace

        puts 'Completed successfully!'
        apache_changed_output.join("\n") if changed

        if dex_changed
          puts ''
          puts 'Restart the ondemand-dex service now.'
          puts ''
          puts 'Suggested command:'
          puts '    sudo systemctl restart ondemand-dex.service'
          puts ''
        end

        ret
      end

      # Starts the OodPortalGenerator CLI
      # @return [void]
      def start(mode, argv = ARGV)
        # Set a cleaner process title
        Process.setproctitle("#{mode} #{argv.join(' ')}")

        # Parse CLI arguments
        OptionParser.new do |parser|
          parser.banner = "Usage: #{mode} [options]"

          case mode
          when 'generate'
            add_generate_opt_parser_attrs(parser)
          when 'update_ood_portal'
            add_update_opt_parser_attrs(parser)
          end

          add_shared_opt_parser_attrs(parser)

          parser.separator ''
          parser.separator 'Default:'
          parser.separator "  #{mode} -c #{config} -t #{template}"
        end.parse!(argv)

        # Render Apache portal config
        case mode
        when 'generate'
          generate
        when 'update_ood_portal'
          exitcode = update_ood_portal
          exit!(exitcode)
        end
      rescue StandardError => e
        warn "#{e.class}:#{e.message}"
        warn e.backtrace
        warn "Run '#{mode} --help' to see a full list of available options."
        exit!(false)
      end

      def add_generate_opt_parser_attrs(parser)
        parser.on('-o', '--output OUTPUT', String, 'File that rendered template is output to') do |v|
          @output = v
        end

        parser.on('-d', '--dex OUTPUT', String, 'File that rendered Dex config is output to') do |v|
          @dex_output = v
        end
      end

      def add_update_opt_parser_attrs(parser)
        parser.on('-r', '--rpm', TrueClass, 'Execution performed during RPM install') do |v|
          @rpm = v
        end

        parser.on('-f', '--force', TrueClass, 'Force replacement of configs even if checksums differ') do |v|
          @force = v
        end

        parser.on('--detailed-exitcodes', TrueClass,
                  'Exit with 3 when changes are made and 4 when changes skipped') do |v|
          @detailed_exitcodes = v
        end
      end

      def add_shared_opt_parser_attrs(parser)
        parser.on('-c', '--config CONFIG', String, 'YAML config file used to render template') do |v|
          @config = v
        end

        parser.on('-t', '--template TEMPLATE', String, 'ERB template that is rendered') do |v|
          @template = v
        end

        parser.on('-i', '--insecure', TrueClass, 'Generate insecure configs if configured') do |v|
          @insecure = v
        end

        parser.on('-v', '--version', 'Print current version') do
          puts "version #{OodPortalGenerator::VERSION}"
          exit
        end

        parser.on('-h', '--help', 'Show this help message') do
          puts parser
          exit
        end
      end
    end
  end
end
