# frozen_string_literal: true

class Workflow
  include ActiveModel::Model

  class DAG
    attr_reader :n, :index, :dependency, :adj_mat, :order, :has_cycle

    def initialize(attributes = {})
      @n = attributes[:launcher_ids].size
      @index = attributes[:launcher_ids].each_with_index.to_h

      create_dependency_list(attributes[:source_ids], attributes[:target_ids], attributes[:launcher_ids])
      create_adjacency_matrix(attributes[:source_ids], attributes[:target_ids], attributes[:launcher_ids])

      topological_sort(attributes[:launcher_ids])
    end

    # This will be use to do Depth-First-Search on graph
    # Save edges are integer representing index of launcher_ids
    def create_adjacency_matrix(from_ids, to_ids, launcher_ids)
      @adj_mat = Array.new(@n) { Array.new(@n, false) }

      m = to_ids.size
      for i in 0...m
        next if from_ids[i].nil? || to_ids[i].nil?
        next unless launcher_ids.include?(from_ids[i]) && launcher_ids.include?(to_ids[i])

        u = index[from_ids[i]]
        v = index[to_ids[i]]
        @adj_mat[u][v] = true
      end
    end

    # This will give out list of launcher_ids whose job id current launcher depends upon
    def create_dependency_list(from_ids, to_ids, launcher_ids)
      @dependency = Hash.new { |h, k| h[k] = [] }

      m = to_ids.size
      for i in 0...m
        next if from_ids[i].nil? || to_ids[i].nil?
        next unless launcher_ids.include?(from_ids[i]) && launcher_ids.include?(to_ids[i])

        @dependency[to_ids[i]] << from_ids[i]
      end
    end

    def topological_sort(launcher_ids)
      @order = []
      @has_cycle = false
      visited = Array.new(@n, false)
      stack = Array.new(@n, false)

      # Depth first search
      define_singleton_method(:dfs) do |parent|
        return if visited[parent]
        visited[parent] = true
        stack[parent] = true

        for child in 0...@n
          if adj_mat[parent][child]
            if stack[child]
              @has_cycle = true  # To detect cycle
              return
            end
            dfs(child)
          end
        end

        # Append the launcher_id in order is there is no other launcher dependent on it
        order.unshift(launcher_ids[parent])
        stack[parent] = false
      end

      for i in 0...@n
        dfs(i) unless visited[i]
        break if @has_cycle
      end
    end

  end

  class << self
    def workflow_dir(project_dir)
      dir = Pathname.new("#{project_dir}/.ondemand/workflows")
      FileUtils.mkdir_p(dir) unless dir.exist?
      dir
    end

    def find(id, project_dir)
      file = "#{workflow_dir(project_dir)}/#{id}.yml"
      Workflow.from_yaml(file, project_dir)
    end

    def all(project_dir)
      Dir.glob("#{workflow_dir(project_dir)}/*.yml").map do |file|
        Workflow.from_yaml(file, project_dir)
      end.compact.sort_by { |s| s.created_at }
    end

    def from_yaml(file, project_dir)
      contents = File.read(file)
      opts = YAML.safe_load(contents).deep_symbolize_keys
      new(opts)
    rescue StandardError, Errno::ENOENT => e
      Rails.logger.warn("Did not find workflow due to error #{e}")
      nil
    end

    def next_id
      SecureRandom.alphanumeric(8).downcase
    end
  end

  attr_reader :id, :name, :description, :project_dir, :created_at, :launcher_ids, :source_ids, :target_ids

  def initialize(attributes = {})
    @id = attributes[:id]
    @name = attributes[:name]
    @description = attributes[:description]
    @project_dir = attributes[:project_dir]
    @created_at = attributes[:created_at]
    @launcher_ids = attributes[:launcher_ids] || []
    @source_ids = attributes[:source_ids] || []
    @target_ids = attributes[:target_ids] || []
  end

  def to_h
    {
      :id => id,
      :name => name,
      :description => description,
      :created_at => created_at,
      :project_dir => project_dir,
      :launcher_ids => launcher_ids,
      :source_ids => source_ids,
      :target_ids => target_ids
    }
  end

  def save
    return false unless valid?(:create)

    @created_at = Time.now.to_i if @created_at.nil?
    @id = Workflow.next_id if id.blank?
    save_manifest(:save)
  end

  def save_manifest(operation)
    FileUtils.touch(manifest_file) unless manifest_file.exist?
    Pathname(manifest_file).write(to_h.deep_stringify_keys.compact.to_yaml)

    true
  rescue StandardError => e
    errors.add(operation, I18n.t('dashboard.jobs_project_save_error', path: manifest_file))
    Rails.logger.warn "Cannot save workflow manifest: #{manifest_file} with error #{e.class}:#{e.message}"
    false
  end

  def collect_errors
    errors.map(&:message).join(', ')
  end

  def destroy!
    FileUtils.remove_entry(manifest_file, true)
    true
  end

  def manifest_file
    Workflow.workflow_dir(@project_dir).join("#{@id}.yml")
  end

  def submit(attributes = {})
    graph = DAG.new(attributes)
    if graph.has_cycle
      errors.add("Submit", "Specified edges form a cycle not directed-acyclic graph")
      return false
    end
    dependency = graph.dependency
    order = graph.order
    Rails.logger.info("Dependency list created by DAG #{dependency}")
    Rails.logger.info("Order in which launcher got submitted #{order}")

    allLaunchers = Launcher.all(attributes[:project_dir])
    jobIdHash = Hash.new { |h, k| }  # launcher-jobId hash

    for id in order
      launcher = allLaunchers.find { |l| l.id == id }
      unless launcher
        Rails.logger.warn("No launcher found for id #{id}, skipping...")
        next
      end
      dependLauncher = dependency[id] || []

      begin
        jobs = dependLauncher.map { |id| jobIdHash[id] }.compact
        opts = submit_launcher_params(launcher, jobs).to_h.symbolize_keys
        jobId = launcher.submit(opts)
        if jobId.nil?
          Rails.logger.warn("Launcher #{id} with opts #{opts} did not return a job ID.")
        else
          jobIdHash[id] = jobId
        end
      rescue => e
        Rails.logger.warn("Launcher #{id} with opts #{opts} failed to submit. Error: #{e.class}: #{e.message}")
      end
    end
  end

  def submit_launcher_params(launcher, dependent_jobs)
    launcher_data = launcher.smart_attributes.each_with_object({}) do |attr, hash|
      hash[attr.id.to_s] = attr.opts[:value]
    end
    launcher_data["afterok"] = Array(dependent_jobs)
    launcher_data
  end

end