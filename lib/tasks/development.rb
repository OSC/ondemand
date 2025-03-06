# frozen_string_literal: true

namespace :dev do
  require_relative 'rake_helper'
  require 'yaml'
  include RakeHelper

  def dev_container_name
    'ood-dev' || ENV['OOD_DEV_CONTAINER_NAME'].to_s
  end

  def term_container_args
    cols = `tput cols 2>/dev/null`.chomp
    rows = `tput lines 2>/dev/null`.chomp

    [
      '-e', "COLUMNS=#{cols}",
      '-e', "LINES=#{rows}"
    ]
  end

  def init_ood_portal
    file = "#{config_directory}/ood_portal.yml"
    return if File.exist?(file)

    require 'io/console'
    puts 'Enter password:'
    plain_password = $stdin.noecho(&:gets).chomp

    File.open(file, File::WRONLY | File::CREAT | File::EXCL, 0o600) do |f|
      f.write({
        'servername'             => 'localhost',
        'port'                   => 8080,
        'listen_addr_port'       => 8080,
        'oidc_remote_user_claim' => 'email',
        'dex'                    => {
          'static_passwords' => [{
            'email'    => "#{user.name}@localhost",
            'password' => plain_password,
            'username' => user.name.to_s,
            'userID'   => '71e63e31-7af3-41d7-add2-575568f4525f'
          }]
        }
      }.to_yaml)
    end
  end

  def container_rt_args
    podman_runtime? ? podman_rt_args : docker_rt_args
  end

  def docker_rt_args
    ['--tmpfs', '/run', '-v', '/sys/fs/cgroup:/sys/fs/cgroup:ro'].freeze
  end

  def podman_rt_args
    [
      '--security-opt', 'label=disable',
      "--uidmap=#{user.uid}:0:1", "--uidmap=0:1:#{user.uid}",
      "--gidmap=#{user.gid}:0:1", "--gidmap=0:1:#{user.gid}",
      user.uid < 1000 ? "--uidmap=#{user.uid+1}:#{user.uid+1}:1000" : nil,
      user.gid < 1000 ? "--gidmap=#{user.gid+1}:#{user.gid+1}:1000" : nil,
    ].compact.tap do |arr|
      arr.concat ['--cap-add', 'sys_ptrace'] unless additional_caps.include?('--privileged')
    end.freeze
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
    ].tap do |mnts|
      unless ENV['OOD_MNT_PORTAL'].nil?
        mnts.concat(['-v',
                     "#{proj_root}/ood-portal-generator:/opt/ood/ood-portal-generator"])
      end
      mnts.concat(['-v', "#{proj_root}/nginx_stage:/opt/ood/nginx_stage"]) unless ENV['OOD_MNT_NGINX'].nil?
      mnts.concat(['-v', "#{proj_root}/mod_ood_proxy:/opt/ood/mod_ood_proxy"]) unless ENV['OOD_MNT_PROXY'].nil?
    end
  end

  def additional_caps
    caps = ENV['OOD_CTR_CAPABILITIES'].to_s
    return ['--privileged'] if caps.include?('privileged')

    caps.to_s.split(',').map do |cap|
      ['--cap-add', cap.downcase]
    end
  end

  desc 'Start development container'
  task :start => ['ensure_dev_files'] do
    Rake::Task['package:dev_container'].invoke unless image_exists?("#{dev_image_name}:latest")

    ctr_args = [container_runtime, 'run', '-p 8080:8080', '-p 5556:5556']
    ctr_args.concat ["--name #{dev_container_name}"]
    ctr_args.concat ['--rm', '--detach']
    ctr_args.concat dev_mounts
    ctr_args.concat additional_caps
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
    ctr_args.concat term_container_args
    ctr_args.concat ['--workdir', user.dir.to_s]
    ctr_args.concat [dev_container_name, '/bin/bash']

    sh ctr_args.join(' ')
  end

  task :bash => [:exec]

  # let advanced users know this, not --tasks
  task :ensure_dev_files do
    [
      :init_ood_portal
    ].each do |initer|
      send(initer)
    end
  end
end
