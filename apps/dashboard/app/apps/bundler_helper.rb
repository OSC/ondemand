require 'bundler'

# inspired by heroku-buildpack-ruby (MIT Licensed)
# some code snippets pulled from there
# https://github.com/heroku/heroku-buildpack-ruby
class BundlerHelper
  def initialize(dir)
    dir = Pathname.new(dir.to_s)

    @gemfile_path = dir.join("Gemfile")
    @gemfile_lock_path = dir.join("Gemfile.lock")
  end

  # Determines wether this Gemfile as the gem 'name'.
  #
  # @param [String] the name of the gem you're looking for
  # @return [Boolean] wether this Gemfile as the gem.
  def has_gem?(name)
    specs.key?(name)
  end

  # The version of the gem 'name'.
  #
  # @param [String] the name of the gem you want the version for
  # @return [String] the version of the gem.
  def gem_version(name)
    if spec = specs[name]
      spec.version
    end
  end

  # The specs of the Gemfile.
  #
  # @return [Array<Hash>] the specs for this Gemfile. Keyed by the spec's name.
  def specs
    @specs     ||= lockfile_parser.specs.each_with_object({}) {|spec, hash| hash[spec.name] = spec }
  end

  # The platforms for this Gemfile.
  #
  # @return [Array<Gem::Platform>] all the platforms supported by this Gemfile.
  def platforms
    @platforms ||= lockfile_parser.platforms
  end

  # The version of bundler.
  #
  # @return [String] The version of bundler.
  def version
    Bundler::VERSION
  end

  # The lockfile parser.
  #
  # @return [Bundler::LockfileParser] the lockfile parser.
  def lockfile_parser
    @lockfile_parser ||= parse_gemfile_lock
  end

  private

  def parse_gemfile_lock
    gemfile_contents = File.read(@gemfile_lock_path)
    Bundler::LockfileParser.new(gemfile_contents)
  end
end
