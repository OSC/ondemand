# frozen_string_literal: true

require_relative 'rake_helper'

namespace :build do
  include RakeHelper

  desc "Build gems"
  task :gems do
    bundle_args = ["--jobs 4", "--retry 2"]
    if VENDOR_BUNDLE
      bundle_args << "--path vendor/bundle"
    end
    if PASSENGER_APP_ENV == "production"
      bundle_args << "--without doc"
    end
    apps.each do |a|
      next unless a.ruby_app?
      chdir a.path do
        sh "bin/bundle install #{bundle_args.join(' ')}"
      end
    end
    infrastructure.each do |a|
      next unless a.gemfile?
      chdir a.path do
        sh "bundle install #{bundle_args.join(' ')}"
      end
    end
  end

  apps.each do |a|
    if a.ruby_app?
      depends = [:gems]
    else
      depends = []
    end
    task a.name.to_sym => depends do |t|
      setup_path = a.path.join("bin", "setup")
      if setup_path.exist? && setup_path.executable?
        sh "PASSENGER_APP_ENV=#{PASSENGER_APP_ENV} #{setup_path}"
      end
    end
  end

  desc "Build all apps"
  task :all => apps.map { |a| a.name }
end

desc "Build OnDemand"
task :build => 'build:all'
