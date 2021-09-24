desc "Test OnDemand"
task :test => 'test:all'

def yarn_app?(path)
  @path = Pathname.new(path)
  @path.join('yarn.lock').exist?
end

namespace :test do
  require_relative 'build_utils'
  include BuildUtils

  testing = {
    'ood-portal-generator': 'spec',
    'nginx_stage': 'spec',
    'apps/dashboard': 'test',
    'apps/myjobs': 'test'
  }

  desc "Setup tests"
  task :setup do
    testing.each_pair do |app, _task|
      chdir PROJ_DIR.join(app.to_s) do

        @path = PROJ_DIR.join(app.to_s)
        if yarn_app?(@path)
          sh 'bin/yarn install'
        end

        sh "bundle install"
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
    sh "shellcheck hooks/k8s-bootstrap/*.sh"
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

  desc "Start test container"
  task :start_test_container, [:mount_args] do |t, task_args|
    args = [ container_runtime, "run", "--name", test_image_name, "--detach", "--rm", "-p", "8080:8080", "-p", "5556:5556"]
    args.concat task_args[:mount_args] || default_mount_args
    args.concat rt_specific_flags
    args.concat ["#{test_image_name}:latest"]

    Rake::Task['test:stop_test_container'].execute
    sh args.join(' ')
  end

  desc "Stop test container"
  task :stop_test_container do
    sh "#{container_runtime} stop #{test_image_name}" if test_container_running?
  end

  def test_container_running?
    `#{container_runtime} inspect --format '{{ .State.Status }}' #{test_image_name} 2>/dev/null || true`.chomp.eql?("running")
  end

  def default_mount_args
    ["-v", "#{PROJ_DIR.join('docker', 'ood_portal.yml')}:/etc/ood/config/ood_portal.yml:ro"]
  end

  desc "Run end to end tests"
  task :e2e => ["package:test_container"] do
    Rake::Task['test:start_test_container'].invoke

    ENV['PATH'] = PROJ_DIR.join('tests').to_s + ":#{ENV['PATH']}"
    Rake::Task['test:e2e_spec'].invoke

    Rake::Task['test:stop_test_container'].execute
  rescue SystemExit => e
    Rake::Task['test:stop_test_container'].execute
    raise e
  rescue => e
    Rake::Task['test:stop_test_container'].execute
    raise e
  end

  task :all => [:unit, :shellcheck]
end
