# OodAppLink is a representation of an HTML link to an OodApp.
class ProjectRequest
  include ActiveModel::Model
  include ActiveModel::Validations

  validate :project_request_validation

  attr_reader :name
  attr_reader :directory
  attr_reader :icon
  attr_reader :description

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
    if name.blank?
      errors.add(:name, message: 'Name is required')
    end

    icon_pattern = %r{\Afa[bsrl]://[\w-]+\z}
    if !icon.blank? && !icon.match?(icon_pattern)
      errors.add(:icon, :invalid_format, message: 'Icon format invalid or missing')
    end

    if !directory.blank? && directory.to_s === Project.dataroot.to_s
      errors.add(:directory, 'Invalid directory')
    end

    if !directory.blank? && Project.lookup_table.map { |_id, directory| directory }.map(&:to_s).include?(directory.to_s)
      errors.add(:directory, 'Directory is already used')
    end
  end


end

