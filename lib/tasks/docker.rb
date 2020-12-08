DOCKER_NAME       = ENV["DOCKER_NAME"] || "ondemand-dev"
DOCKER_PORT       = ENV["DOCKER_PORT"] || '8080'

namespace :docker do
    desc "Build Docker container"
    task :build do
      sh "docker build -t #{DOCKER_NAME} ."
    end

    desc "Run Docker container"
    task :run do
      sh "docker run -p #{DOCKER_PORT}:8080 -p 5556:5556 -v '#{PROJ_DIR}:/ondemand' --name #{DOCKER_NAME} --rm --detach #{DOCKER_NAME}"
    end

    desc "Kill Docker container"
    task :kill do
      sh "docker kill #{DOCKER_NAME}"
    end

    desc "Connect to Docker container"
    task :connect do
      sh "docker exec -it #{DOCKER_NAME} /bin/bash"
    end

    desc "Use docker to do development, build run and connect to container"
    task :development => [:build, :run, :connect]
  end