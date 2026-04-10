# frozen_string_literal: true

# HpcModule is a class representing a module you'd see on an HPC system.
class HpcModule
  class << self
    def all(cluster: nil)
      if cluster
        Rails.cache.fetch("modules_#{cluster}", expires_in: 24.hours) do
          file = "#{Configuration.module_file_dir}/#{cluster}.json"
          if File.file?(file) && File.readable?(file)
            begin
              data = JSON.parse(File.read(file))

              # Group entries by name+version and aggregate dependency sets
              grouped = Hash.new { |h, k| h[k] = { name: k[0], version: k[1], dependencies: [], hidden: false } }

              # Iterate through the data and populate the grouped hash
              data.each do |name, spider_output|
                spider_output.each do |_, mod|
                  version = mod['Version']
                  key = [name, version]
                  grouped[key][:hidden] ||= !!mod['hidden']

                  deps = mod['parentAA']
                  # If parentAA is an array of dependency pairs; append them
                  if deps.is_a?(Array)
                    grouped[key][:dependencies].concat(deps)
                  end
                end
              end

              # Convert grouped hash to HpcModule instances, ensuring dependencies are unique
              grouped.values.map do |info|
                deps = info[:dependencies].uniq
                HpcModule.new(info[:name], version: info[:version], dependencies: deps, cluster: cluster, hidden: info[:hidden])
              end.reject(&:hidden?)
            rescue StandardError => e
              Rails.logger.warn("Did not read #{file} correctly because #{e.class}:#{e.message}")
              []
            end
          else
            Rails.logger.warn("File #{file} is unreadable.")
            []
          end
        end
      else
        Configuration.job_clusters.flat_map do |cluster|
          all(cluster: cluster.id)
        end
      end
    end

    def all_versions(module_name)
      Configuration.job_clusters.map do |cluster|
        all(cluster: cluster.id).select { |m| m.name == module_name.to_s }
      end.flatten.uniq(&:to_s).sort_by(&:version).reverse
    end

  end

  attr_reader :name, :version, :dependencies, :cluster, :hidden
  alias hidden? hidden

  def initialize(name, version: nil, dependencies: nil, cluster: nil, hidden: false)
    @name = name
    @version = version.to_s if version
    @dependencies = dependencies
    @cluster = cluster
    @hidden = hidden
  end

  def to_s
    @to_s ||= version.nil? ? name : "#{name}/#{version}"
  end

  def default?
    version.nil?
  end

  def on_cluster?(cluster_name)
    HpcModule.all(cluster: cluster_name).any? { |m| m.to_s == to_s }
  end
end
