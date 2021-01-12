desc "Test OnDemand"
task :test => 'test:all'

namespace :test do
  require_relative 'build_utils'
  include BuildUtils

  testing = {
    'ood-portal-generator': 'spec',
    'nginx_stage': 'spec',
    'apps/activejobs': 'spec',
    'apps/dashboard': 'test',
    'apps/file-editor': 'test',
    'apps/myjobs': 'test'
  }

  desc "Setup tests"
  task :setup do
    testing.each_pair do |app, _task|
      chdir PROJ_DIR.join(app.to_s) do
        sh "bundle install --with development test"
        sh "rake assets:precompile" if app.to_s == "apps/dashboard"
      end
    end
  end

  desc "Run unit tests"
  task :unit => [:setup] do
    testing.each_pair do |app, task|
      chdir PROJ_DIR.join(app.to_s) do
        sh "bundle exec rake #{task}"
      end
    end
  end

  desc "Run shellcheck"
  task :shellcheck do
    sh "shellcheck -x ood-portal-generator/sbin/update_ood_portal"
    sh "shellcheck -x nginx_stage/sbin/nginx_stage"
    sh "shellcheck nginx_stage/sbin/update_nginx_stage"
  end

  begin
    require "rspec/core/rake_task"
    RSpec::Core::RakeTask.new(:e2e_spec) do |task|
      task.pattern = "#{PROJ_DIR.join('spec', 'e2e')}/*_spec.rb"
      task.rspec_opts = ['--format documentation']
    end
  rescue LoadError
  end

  desc "Get chromedriver"
  task :chromedriver, [:version] do |t, args|
    version = args[:version] || '87.0.4280.88'
    uname = `uname -s`
    case uname.chomp
    when 'Darwin'
      file = 'chromedriver_mac64.zip'
    when 'Linux'
      file = 'chromedriver_linux64.zip'
    end
    url = "https://chromedriver.storage.googleapis.com/#{version}/#{file}"
    sh "curl -o tests/#{file} #{url}"
    chdir PROJ_DIR.join("tests") do
      sh "unzip -o #{file}"
    end
  end

  def start_test_container
    args = [ container_runtime, "run", "--name", test_image_name, "--detach", "--rm", "-p", "8080:8080", "-p", "5556:5556"]
    args.concat mount_args
    args.concat rt_specific_flags
    args.concat ["#{test_image_name}:latest"]

    sh args.join(' ')
  end

  def stop_test_container
    sh "#{container_runtime} stop #{test_image_name}"
  end

  def mount_args
    ["-v", "#{PROJ_DIR.join('docker', 'ood_portal.yml')}:/etc/ood/config/ood_portal.yml:ro"]
  end

  def rt_specific_flags
    if podman_runtime?
      ["--security-opt", "label=disable"] # SELinux doesn't like it if you're mounting from $HOME
    else
      []
    end
  end

  desc "Run end to end tests"
  task :e2e => ["package:test_container"] do
    start_test_container
    ENV['PATH'] = PROJ_DIR.join('tests').to_s + ":#{ENV['PATH']}"
    Rake::Task['test:e2e_spec'].invoke
    stop_test_container
  rescue SystemExit => e
    stop_test_container
    raise e
  rescue => e
    stop_test_container
    raise e
  end

  task :all => [:unit, :shellcheck]
end
