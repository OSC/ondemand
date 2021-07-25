# frozen_string_literal: true

namespace :dev do

  require_relative 'build_utils'
  require 'yaml'
  require 'bcrypt'
  include BuildUtils

  def dev_container_name
    'ood-dev' || "#{ENV['OOD_DEV_CONTAINER_NAME']}"
  end

  def init_ood_portal
    file = "#{config_directory}/config/ood_portal.yml"
    return if File.exists?(file)

    FileUtils.mkdir_p("#{config_directory}/config")

    File.open(file, File::WRONLY|File::CREAT|File::EXCL) do |f|
      f.write({
        'servername': 'localhost',
        'port': 8080,
        'listen_addr_port': 8080,
        'oidc_remote_user_claim': 'email',
        'dex': {
          'connectors':  [{
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
    return if File.exists?(file)

    require 'io/console'
    puts 'Enter password:'
    plain_password = STDIN.noecho(&:gets).chomp
    bcrypted = BCrypt::Password.create(plain_password)

    content = <<CONTENT
enablePasswordDB: true
staticPasswords:
- email: "#{user.name}@localhost"
  hash: "#{bcrypted}"
  username: "#{user.name}"
  userID: "71e63e31-7af3-41d7-add2-575568f4525f"
CONTENT

    File.open(file, File::WRONLY|File::CREAT|File::EXCL) do |f|
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
    ].freeze
  end

  def config_directory
    @config_directory ||= begin
      dir = "#{user.dir}/.config/ondemand/container"
      FileUtils.mkdir_p(dir)
      dir
    end
  end

  def dev_mounts
    [ 
      '-v', "#{config_directory}:/etc/ood",
      '-v', "#{user.dir}/ondemand:#{user.dir}/ondemand"
    ]
  end

  desc 'Start development container'
  task :start => ['package:dev_container', 'ensure_dev_files'] do
    ctr_args = [ container_runtime, 'run', '-p 8080:8080', '-p 5556:5556' ]
    ctr_args.concat ["--name #{dev_container_name}" ]
    ctr_args.concat [ '--rm', '--detach' ]
    ctr_args.concat [ '-e', 'OOD_STATIC_USER=/etc/ood/config/static_user.yml' ]
    ctr_args.concat dev_mounts
    ctr_args.concat container_rt_args

    ctr_args.concat [ "#{dev_image_name}:latest" ]
    sh ctr_args.join(' ')
  end

  desc 'Stop development container'
  task :stop do
    sh "#{container_runtime} stop #{dev_container_name}"
  end

  desc 'Restart development container'
  task :restart => [:stop, :start]

  desc 'Bash exec into the development container'
  task :exec do
    ctr_args = [ container_runtime, 'exec', '-it' ]
    # home is set to /root? could be bug for me
    ctr_args.concat [ '-e', "HOME=#{user.dir}" ]
    ctr_args.concat [ '--workdir', user.dir.to_s ]
    ctr_args.concat [ dev_container_name, '/bin/bash' ]

    sh ctr_args.join(' ')
  end

  task :bash => [:exec]

  # let advanced users know this, not --tasks
  task :ensure_dev_files do
      [
        :init_ood_portal,
        :init_ctr_user
      ].each do |initer|
        self.send(initer)
      end
  end
end
