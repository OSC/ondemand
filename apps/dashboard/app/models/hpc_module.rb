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

  def ==(other)
    to_s == other.to_s
  end
  alias eql? ==

  def default?
    version.nil?
  end
end
