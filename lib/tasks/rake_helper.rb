# frozen_string_literal: true
require "pathname"

module RakeHelper
  def infrastructure
    [
      'mod_ood_proxy',
      'nginx_stage',
      'ood_auth_map',
      'ood-portal-generator',
    ].map { |d| Component.new(d) }
  end

  def apps
    Dir["#{APPS_DIR}/*"].map { |d| Component.new(d) }
  end

  def ruby_apps
    apps.select(&:ruby_app?)
  end

  def yarn_apps
    apps.select(&:package_json?)
  end

  class Component
    attr_reader :name
    attr_reader :path

    def initialize(app)
      @name = File.basename(app)
      @path = Pathname.new(app)
    end

    def ruby_app?
      @path.join('config.ru').exist?
    end

    def node_app?
      @path.join('app.js').exist?
    end

    def package_json?
      @path.join('package.json').exist?
    end

    def gemfile?
      @path.join('Gemfile.lock').exist?
    end
  end
end
