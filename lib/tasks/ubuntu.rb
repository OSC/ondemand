require_relative 'build_utils'
include BuildUtils

namespace :package do

  desc "Package Ubuntu"
  task :ubuntu => 'ubuntu:build'

  namespace :ubuntu do
  
    task :build do
      Rake::Task['build:build_in_image'].invoke('ubuntu', '20.04')
    end
  end
end
