// This class will help us to detect if any new edge can lead to cycle or not
// Thus we can alert user to avoid that edge thus resolving cycle issue on UI

// Directed Acyclic Graph
export class DAG {
  #launcher_list;
  #adjacency_list;
  #visited;
  #stack;
  #has_cycle;

  constructor() {
    this.#launcher_list = new Set();
    this.#adjacency_list = {};
  }

  reset() {
    this.#launcher_list = new Set();
    this.#adjacency_list = {};
  }

  addEdge(fromId, toId) {
    if (!this.#launcher_list.has(fromId)) {
      this.#launcher_list.add(fromId);
    }

    if (!this.#launcher_list.has(toId)) {
      this.#launcher_list.add(toId);
    }

    if (!this.#adjacency_list[fromId]) {
      this.#adjacency_list[fromId] = [];
    }
    this.#adjacency_list[fromId].push(toId);

    this.#has_cycle = false;
    this.#visited = new Set();
    this.#stack = new Set();
    this.#launcher_list.forEach(l => this.#detectCycle(l));

    // Remove the added edge from the adjacency list if cycle detected
    if (this.#has_cycle === true) {
      this.#adjacency_list[fromId].pop();
    }
  }

  removeEdge(fromId, toId) {
    if (!this.#adjacency_list[fromId]) return;

    if (this.#adjacency_list[fromId].includes(toId)) {
      this.#adjacency_list[fromId] = this.#adjacency_list[fromId].filter(x => x !== toId);
    }
  }

  removeLauncher(id) {
    this.#launcher_list.delete(id);
    delete this.#adjacency_list[id];

    for (const from in this.#adjacency_list) {
      this.#adjacency_list[from] = this.#adjacency_list[from].filter(x => x !== id);
    }
  }

  hasCycle() {
    return this.#has_cycle;
  }

  // Basic dfs on graph to find a cycle
  #detectCycle(id) {
    if (this.#stack.has(id)) {
      this.#has_cycle = true;
      return;
    }
    if (this.#visited.has(id)) return;

    this.#stack.add(id);
    this.#visited.add(id);
    for (const l of this.#adjacency_list[id] || []) {
      this.#detectCycle(l);
    }
    this.#stack.delete(id);
  }
}