desc "Test OnDemand"
task :test => 'test:all'

namespace :test do
  require_relative 'build_utils'
  include BuildUtils

  testing = {
    'ood-portal-generator': 'spec',
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

  def start_test_container
    args = [ container_runtime, "run", "--name", test_image_name, "--detach", "--rm", "-p", "8080:80"]
    args.concat mount_args
    args.concat rt_specific_flags
    args.concat ["#{test_image_name}:latest"]

    sh args.join(' ')
  end

  def stop_test_container
    sh "#{container_runtime} stop #{test_image_name}"
  end

  def e2e_test
    sh "sleep 2"
    sh "curl -L -vv -f -u ood:ood localhost:8080"
  end

  def mount_args
    ["-v", "#{TASK_DIR}/container_files/test/ood_portal.yml:/etc/ood/config/ood_portal.yml:ro"]
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
    e2e_test
    stop_test_container
  rescue => e
    stop_test_container
    raise e
  end

  task :all => [:unit, :shellcheck]
end