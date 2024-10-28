# frozen_string_literal: true

require_relative 'rake_helper'
require 'securerandom'

namespace :build do
  include RakeHelper

  desc 'Build gems'
  task :gems do
    bundle_args = ['--jobs 4', '--retry 2']
    bundle_args << '--path vendor/bundle' if VENDOR_BUNDLE
    bundle_env = "BUNDLE_WITHOUT='doc test package development'" if PASSENGER_APP_ENV == 'production'

    apps.each do |a|
      next unless a.ruby_app?

      chdir a.path do
        sh "#{bundle_env} bin/bundle install #{bundle_args.join(' ')}"
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
    depends = if a.ruby_app?
                [:gems]
              else
                []
              end
    task a.name.to_sym => depends do |_t|
      setup_path = a.path.join('bin', 'setup')
      # SECRET_KEY_BASE is actually generated & used elsewhere. However, we have 
      # to supply it now at build time for turbo.
      env = "PASSENGER_APP_ENV=#{PASSENGER_APP_ENV} SECRET_KEY_BASE=#{SecureRandom.uuid}"
      sh "#{env} #{setup_path}" if setup_path.exist? && setup_path.executable?
    end
  end

  desc 'Build all apps'
  task :all => apps.map(&:name)
end

desc 'Build OnDemand'
task :build => 'build:all'
