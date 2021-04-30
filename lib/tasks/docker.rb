DOCKER_NAME = ENV["DOCKER_NAME"] || "ondemand-dev"

namespace :docker do
    desc "Build Docker container"
    task :build => ["package:test_container"]

    desc "Run Docker container"
    task :run => :build do
      args = [ container_runtime, 'run', '-p 8080:8080', '-p 5556:5556', "--name #{DOCKER_NAME}" ]
      args.concat [ "--rm", "--detach", "-v '#{PROJ_DIR}:/ondemand'" ]
      args.concat default_mount_args
      args.concat [ "#{test_image_name}:latest" ]
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