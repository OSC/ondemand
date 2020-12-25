DOCKER_NAME = ENV["DOCKER_NAME"] || "ondemand-dev"

namespace :docker do
    desc "Build Docker container"
    task :build => ["package:latest_container"] do
      file = "Dockerfile.test"
      build_cmd = podman_runtime? ? buildah_build_cmd(file, DOCKER_NAME) : docker_build_cmd(file, DOCKER_NAME)
      sh build_cmd unless image_exists?("#{DOCKER_NAME}:#{image_tag}")
      sh tag_latest_container_cmd(DOCKER_NAME)
    end

    desc "Run Docker container"
    task :run do
      args = [ container_runtime, 'run', '-p 8080:8080', '-p 5556:5556', "--name #{DOCKER_NAME}" ]
      args.concat [ "--rm", "--detach", "-v '#{PROJ_DIR}:/ondemand'" ]
      args.concat mount_args
      args.concat [ "#{DOCKER_NAME}:latest" ]
      sh args.join(' ')
    end

    desc "Kill Docker container"
    task :kill do
      sh "#{container_runtime} kill #{DOCKER_NAME}"
    end

    desc "Connect to Docker container"
    task :connect do
      sh "#{container_runtime} exec -it #{DOCKER_NAME} /bin/bash"
    end

    desc "Use docker to do development, build run and connect to container"
    task :development => [:build, :run, :connect]
  end