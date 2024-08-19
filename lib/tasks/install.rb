# frozen_string_literal: true

require_relative 'rake_helper'

directory INSTALL_ROOT.to_s

desc 'Install OnDemand'
task :install => 'install:all'

namespace :install do
  include RakeHelper

  desc 'Install OnDemand infrastructure'
  task :infrastructure => [INSTALL_ROOT] do
    infrastructure.each do |infra|
      sh "cp -r #{infra.name} #{INSTALL_ROOT}/"
    end
  end

  desc 'Install OnDemand apps'
  task :apps => [INSTALL_ROOT] do
    sh "cp -r #{APPS_DIR} #{INSTALL_ROOT}/"
  end

  namespace :infrastructure do
    desc 'Install infrastructure files'
    task :files do
      infrastructure_files.each do |file|
        src = render_package_file(file[:src])
        FileUtils.mkdir_p(File.dirname(file[:dest]), verbose: true) unless Dir.exist?(File.dirname(file[:dest]))
        FileUtils.cp(src, file[:dest], verbose: true)
        FileUtils.chmod(file[:mode], file[:dest], verbose: true)
      end
    end
  end

  desc 'Install OnDemand infrastructure and apps'
  task :all => [:infrastructure, :apps, 'infrastructure:files']
end
