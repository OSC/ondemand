# OodAppLink is a representation of an HTML link to an OodApp.
class ProjectRequest
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_reader :name
  attr_reader :directory
  attr_reader :icon
  attr_reader :description

  validates :name, presence: { message: :required }
  validates :icon, format: { with: %r{\Afa[bsrl]://[\w-]+\z}, allow_blank: true, message: :format }
  validates :directory, exclusion: { in: [Project.dataroot.to_s], message: :invalid }
  validate :project_request_validation

  def initialize(config = {})
    config = config.to_h.compact.symbolize_keys

    @name         = config.fetch(:name, "").to_s
    @directory    = config.fetch(:directory, "").to_s
    @icon         = config.fetch(:icon, "").to_s
    @description  = config.fetch(:description, "").to_s
  end

  def to_h
    instance_variables.each_with_object({}) do |var, hash|
      hash[var.to_s.gsub('@', '').to_sym] = instance_variable_get(var)
    end
  end

  private

  def project_request_validation
    if !directory.blank? && Project.lookup_table.map { |_id, directory| directory }.map(&:to_s).include?(directory.to_s)
      errors.add(:directory, :used)
    end
  end


end

