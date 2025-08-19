# Helper for workflow manager.
module WorkflowsHelper

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

    # Depth first search
    def dfs(parent, visited, stack, launcher_ids)
      return if visited[parent]
      visited[parent] = true
      stack[parent] = true

      for child in 0...@n
        if adj_mat[parent][child]
          if stack[child]
            @has_cycle = true  # To detect cycle
            return
          end
          dfs(child, visited, stack, launcher_ids)
        end
      end

      # Append the launcher_id in order is there is no other launcher dependent on it
      order.unshift(launcher_ids[parent])
      stack[parent] = false
    end

    def topological_sort(launcher_ids)
      @order = []
      @has_cycle = false
      visited = Array.new(@n, false)
      stack = Array.new(@n, false)

      for i in 0...@n
        dfs(i, visited, stack, launcher_ids) unless visited[i]
        break if @has_cycle
      end
    end

  end

end
