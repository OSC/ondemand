# frozen_string_literal: true

module Jobs
  class Project
    include ActiveModel::Model

    class << self
      def all
        # return [Array] of all projects in ~/ondemand/data/sys/projects
        return [] unless dataroot.directory? && dataroot.executable? && dataroot.readable?

        dataroot.children.map do |d|
          Jobs::Project.new({ :dir => d.basename })
        rescue StandardError => e
          Rails.logger.warn("Didn't create project. #{e.message}")
          nil
        end.compact
      end

      def find(project_path)
        full_path = dataroot.join(project_path)
        return nil unless full_path.directory?

        Jobs::Project.new({ dir: full_path })
      end

      def dataroot
        Rails.logger.debug("project path is: #{OodAppkit.dataroot.join('projects')}")

        OodAppkit.dataroot.join('projects').tap do |p|
          p.mkpath unless p.exist?
        rescue StandardError => e
          Pathname.new('')
        end
      end
    end

    attr_reader :dir

    def initialize(args = {})
      @dir = args.fetch(:dir, nil).to_s
    end

    def config_dir
      Pathname.new("#{absolute_dir}/.ondemand").tap { |p| p.mkpath unless p.exist? }
    end

    def absolute_dir
      Jobs::Project.dataroot.join(dir)
    end

    def save!
      true
    end

    def destroy!
      FileUtils.remove_dir(absolute_dir, force = true)
    end
  end
end
