require_relative 'build_utils'
include BuildUtils

namespace :package do

  desc "Package Ubuntu"
  task :ubuntu => 'ubuntu:build'

  namespace :ubuntu do
  
    task build: ['build:build_box'] do
      sh "mkdir -p build/ubuntu"
      Rake::Task['build:build_in_image'].invoke
    end
  end 
end