# frozen_string_literal: true

require 'fileutils'

desc 'Lint OnDemand'
task :lint => 'lint:all'

namespace :lint do
  require_relative 'rake_helper'
  include RakeHelper

  DEFAULT_PATTERNS = [
    'apps/**/*.rb',
    'lib/**/*.rb',
    'nginx_stage/**/*.rb',
    'ood-portal-generator/**/*.rb',
    'spec/**/*.rb'
  ].freeze

  begin
    require 'rubocop/rake_task'
    RuboCop::RakeTask.new(:rubocop, [:path]) do |t, args|
      t.options = ["--config=#{PROJ_DIR.join('.rubocop.yml')}"]
      t.patterns = args[:path].nil? ? DEFAULT_PATTERNS : [args[:path]]
    end
  rescue LoadError
  end

  begin
    require 'rubocop/rake_task'
    RuboCop::RakeTask.new(:random) do |t, _args|
      all_files = Dir.glob(DEFAULT_PATTERNS).reject { |f| f.include?('vendor/bundle') }
      one_file = all_files[Random.rand(all_files.size)]

      t.options = ["--config=#{PROJ_DIR.join('.rubocop.yml')}", '-A', '--fail-level', 'fatal']
      t.patterns = [one_file]
    end
  rescue LoadError
  end

  desc 'Setup .rubocop.yml files'
  task :setup do
    source = PROJ_DIR.join('.rubocop.yml')
    (ruby_apps + infrastructure).each do |app|
      FileUtils.cp(source, app.path.join('.rubocop.yml'), verbose: true)
    end
  end

  task :all => [:rubocop]
end
