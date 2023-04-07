# frozen_string_literal: true

require 'bundler'

# Inspired by heroku-buildpack-ruby (MIT Licensed).
# some code snippets pulled from there.
# https://github.com/heroku/heroku-buildpack-ruby
class BundlerHelper
  def initialize(dir)
    dir = Pathname.new(dir.to_s)

    @gemfile_path = dir.join('Gemfile')
    @gemfile_lock_path = dir.join('Gemfile.lock')
  end

  def has_gem?(name)
    specs.key?(name)
  end

  def gem_version(name)
    if spec = specs[name]
      spec.version
    end
  end

  def specs
    @specs     ||= lockfile_parser.specs.each_with_object({}) { |spec, hash| hash[spec.name] = spec }
  end

  def platforms
    @platforms ||= lockfile_parser.platforms
  end

  def version
    Bundler::VERSION
  end

  def lockfile_parser
    @lockfile_parser ||= parse_gemfile_lock
  end

  private

  def parse_gemfile_lock
    gemfile_contents = File.read(@gemfile_lock_path)
    Bundler::LockfileParser.new(gemfile_contents)
  end
end
