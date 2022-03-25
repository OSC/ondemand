# frozen_string_literal: true

# HpcModule is a class representing a module you'd see on an HPC system.
class HpcModule
  class << self
    def all(cluster)
      Rails.cache.fetch("modules_#{cluster}", expires_in: 24.hours) do
        file = "#{Configuration.module_file_dir}/#{cluster}.json"
        if File.file?(file) && File.readable?(file)
          begin
            JSON.parse(File.read(file)).map do |name, spider_output|
              spider_output.map do |_, mod|
                HpcModule.new(name, version: mod['Version'])
              end
            end.flatten.uniq(&:to_s)
          rescue StandardError => e
            Rails.logger.warn("Did not read #{file} correctly because #{e.class}:#{e.message}")
            []
          end
        else
          Rails.logger.warn("File #{file} is unreadable.")
          []
        end
      end
    end
  end

  attr_reader :name, :version

  def initialize(name, version: nil)
    @name = name
    @version = version.to_s if version
  end

  def to_s
    @to_s ||= version.nil? ? name : "#{name}/#{version}"
  end

  # Equivlance is based on the a string of the name and version of 
  # the module, much like in real life.
  # Two modules are equal if they have the same name and version.
  #
  # We want to be sure that uniqeness is by value, not by
  # identity.
  #
  #   new('rstudio', vesrion: 3) == new('rstudio', version: 3) is true.
  #   and
  #   new('rstudio', 3) == 'rstudio/3' is also true
  def ==(other)
    to_s == other.to_s
  end
  alias eql? ==

  def default?
    version.nil?
  end
end
