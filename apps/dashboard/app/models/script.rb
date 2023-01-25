# frozen_string_literal: true

# Project classes represent projects users create to run HPC jobs.
class Script
  include ActiveModel::Model
  include ActiveModel::Validations

  validates :name, presence: true

  attr_reader :name, :batch_connect_form, :project_id

  def initialize(params = {})
  end
end