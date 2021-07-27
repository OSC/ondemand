# frozen_string_literal: true

namespace :dev do
  require_relative 'build_utils'
  require 'yaml'
  require 'bcrypt'
  include BuildUtils

  def dev_container_name
    'ood-dev' || ENV['OOD_DEV_CONTAINER_NAME'].to_s
  end

  def init_ood_portal
    file = "#{config_directory}/ood_portal.yml"
    return if File.exist?(file)

    File.open(file, File::WRONLY|File::CREAT|File::EXCL) do |f|
      f.write({
        'servername': 'localhost',
        'port': 8080,
        'listen_addr_port': 8080,
        'oidc_remote_user_claim': 'email',
        'dex': {
          'connectors': [{
            'type': 'mockCallback',
            'id': 'mock',
            'name': 'Mock'
          }]
        }
      }.to_yaml)
    end
  end

  def init_ctr_user
    file = "#{config_directory}/static_user.yml"
    return if File.exist?(file)

    require 'io/console'
    puts 'Enter password:'
    plain_password = $stdin.noecho(&:gets).chomp
    bcrypted = BCrypt::Password.create(plain_password)

    content = <<~CONTENT
      enablePasswordDB: true
      staticPasswords:
      - email: "#{user.name}@localhost"
        hash: "#{bcrypted}"
        username: "#{user.name}"
        userID: "71e63e31-7af3-41d7-add2-575568f4525f"
    CONTENT

    File.open(file, File::WRONLY | File::CREAT | File::EXCL) do |f|
      f.write(content)
    end
  end

  def container_rt_args
    podman_runtime? ? podman_rt_args : docker_rt_args
  end

  def docker_rt_args
    [].freeze
  end

  def podman_rt_args
    [
      '--userns', 'keep-id',
      '--cap-add', 'sys_ptrace',
      '--security-opt', 'label=disable'
    ].freeze
  end

  def config_directory
    @config_directory ||= begin
      base_dir = "#{user.dir}/.config/ondemand/container/config".tap { |dir| FileUtils.mkdir_p(dir) }
      base_dir
    end
  end

  def dev_mounts
    [
      '-v', "#{config_directory}:/etc/ood/config",
      '-v', "#{user.dir}/ondemand:#{user.dir}/ondemand"
    ]
  end

  desc 'Start development container'
  task :start => ['ensure_dev_files'] do
    Rake::Task['package:dev_container'].invoke unless image_exists?("#{dev_image_name}:latest")

    ctr_args = [container_runtime, 'run', '-p 8080:8080', '-p 5556:5556']
    ctr_args.concat ["--name #{dev_container_name}"]
    ctr_args.concat ['--rm', '--detach']
    ctr_args.concat ['-e', 'OOD_STATIC_USER=/etc/ood/config/static_user.yml']
    ctr_args.concat dev_mounts
    ctr_args.concat container_rt_args

    ctr_args.concat ["#{dev_image_name}:latest"]
    sh ctr_args.join(' ')
  end

  desc 'Stop development container'
  task :stop do
    sh "#{container_runtime} stop #{dev_container_name}"
  end

  desc 'See the development container\'s logs'
  task :logs do
    sh "#{container_runtime} logs #{dev_container_name}"
  end

  desc 'Restart development container'
  task :restart => [:stop, :start]

  desc 'Rebuild the ood-dev:latest container'
  task :rebuild => ['package:dev_container']

  desc 'Bash exec into the development container'
  task :exec do
    ctr_args = [container_runtime, 'exec', '-it']
    # home is set to /root? could be bug for me
    ctr_args.concat ['-e', "HOME=#{user.dir}"]
    ctr_args.concat ['--workdir', user.dir.to_s]
    ctr_args.concat [dev_container_name, '/bin/bash']

    sh ctr_args.join(' ')
  end

  task :bash => [:exec]

  # let advanced users know this, not --tasks
  task :ensure_dev_files do
    [
      :init_ood_portal,
      :init_ctr_user
    ].each do |initer|
      send(initer)
    end
  end
end
