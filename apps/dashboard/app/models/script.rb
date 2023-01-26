# frozen_string_literal: true

# Project classes represent projects users create to run HPC jobs.
class Script
  include ActiveModel::Model
  include ActiveModel::Validations

  validates :name, presence: true

  attr_reader :name, :batch_connect_form, :project_id

  # Static methods go inside the self block
  class << self
    def all(project_id)
      # return [] unless dataroot.directory? && dataroot.executable? && dataroot.readable?

      # dataroot.children.map do |d|
      #   Project.new({ :name => d.basename })
      # rescue StandardError => e
      #   Rails.logger.warn("Didn't create project. #{e.message}")
      #   nil
      # end.compact
      return []
    end
  end

  def initialize(attributes = {})
    @project_id = attributes[:project_id]
    @batch_connect_form = attributes[:batch_connect_form]
  end
end
