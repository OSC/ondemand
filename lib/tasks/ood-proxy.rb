# frozen_string_literal: true

require_relative 'build_utils'
include BuildUtils

namespace :build do
  def proxy_container_name
    'ood-proxy-rs' || ENV['OOD_PROXY_CONTAINER_NAME'].to_s
  end

  task :proxy_docker do
    sh build_cmd("Dockerfile.proxy", proxy_container_name)
    sh tag_latest_container_cmd(proxy_container_name)
  end

  task :proxy do
    build_args = ['cargo', 'build']
    build_args.concat ['--release']
    build_args.concat ["--manifest-path #{PROJ_DIR.join('ood-proxy-rs')}/Cargo.toml"]

    sh build_args.join(' ')
  end
end

namespace :proxy do
  task :start do
    Rake::Task['build:proxy'] unless image_exists?("#{proxy_container_name}:#{image_tag}")

    ctr_args = [container_runtime, 'run', "#{proxy_container_name}"]
    ctr_args.concat ["--name #{proxy_container_name}"]
    ctr_args.concat ["#{proxy_container_name}:latest"]
  
    sh ctr_args.join(' ')
  end

  task :stop do
    sh "#{container_runtime} stop #{proxy_container_name}"
  end

  task :restart => [:stop, :start]
end
