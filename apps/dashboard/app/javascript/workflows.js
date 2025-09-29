import { DAG } from './dag.js';

(() => {
  const stage = document.getElementById('stage');
  const edges_svg = document.getElementById('edges');
  const add_launcher_button = document.getElementById('btn-add');
  const connect_launcher_button = document.getElementById('btn-connect');
  const delete_launcher_button = document.getElementById('btn-delete-launcher');
  const delete_edge_button = document.getElementById('btn-delete-edge');
  const selected_launcher = document.getElementById('select_launcher');
  const base_launcher_url = document.getElementById('base-launcher-url').value;
  const dag = new DAG;
  const styles = getComputedStyle(document.documentElement);
  const grid_cols = parseInt(styles.getPropertyValue('--grid_cols'));
  const grid_rows = parseInt(styles.getPropertyValue('--grid_rows'));
  const cell_w = parseInt(styles.getPropertyValue('--cell_w')) + parseInt(styles.getPropertyValue('--gap'));
  const cell_h = parseInt(styles.getPropertyValue('--cell_h')) + parseInt(styles.getPropertyValue('--gap'));

  const boxes = new Map();
  const edges = [];
  let selected_launcher_id = null;
  let selected_edge = null;
  let connect_mode = false;
  let connect_queue = null;

  function stageRect() { return stage.getBoundingClientRect(); }

  function gridSpawn() {
    const cols = 12;
    const rows = 6;
    for (let r = 1; r <= rows; r++) {
      for (let c = 1; c <= cols; c++) {
        if (!document.querySelector(`.launcher-item[data-row="${r}"][data-col="${c}"]`)) {
          return { row: r, col: c };
        }
      }
    }
    alert("No empty grid cells available!");
    return null;
  }

  function snapToGrid(x, y) {
    const col = Math.max(1, Math.min(grid_cols, Math.round(x / cell_w) + 1));
    const row = Math.max(1, Math.min(grid_rows, Math.round(y / cell_h) + 1));
    return { row, col };
  }

  function cellToXY(row, col) {
    return {
      x: (col - 1) * cell_w + 10, // +padding
      y: (row - 1) * cell_h + 10
    };
  }

  function isCellOccupied(row, col, excludeId = null) {
    for (const [id, box] of boxes.entries()) {
      if (id !== excludeId && box.row === row && box.col === col) {
        return true;
      }
    }
    return false;
  }

  function pointerInStage(e) {
    const r = stageRect();
    const x = (e.clientX ?? e.touches?.[0].clientX) - r.left;
    const y = (e.clientY ?? e.touches?.[0].clientY) - r.top;
    return { x, y };
  }

  function updateBoxPosition(id, x, y) {
    const b = boxes.get(id);
    if (!b) return;
    b.x = x; b.y = y;
    b.el.style.left = x + 'px';
    b.el.style.top  = y + 'px';
    edges.forEach(edge => { if (edge.fromId===id || edge.toId===id) updateEdgeLine(edge); });
  }

  function intersectRect(cx, cy, w, h, dx, dy) {
    const absDx = Math.abs(dx);
    const absDy = Math.abs(dy);
    let scale = 0.5 / Math.max(absDx/w, absDy/h);
    scale = Math.min(scale, 1);
    return { x: cx + dx * scale, y: cy + dy * scale };
  }

  function updateEdgeLine(edge) {
    const from = boxes.get(edge.fromId);
    const to = boxes.get(edge.toId);
    if (!from || !to) return;

    const x1 = from.x, y1 = from.y, w1 = from.w, h1 = from.h;
    const x2 = to.x, y2 = to.y, w2 = to.w, h2 = to.h;

    const cx1 = x1 + w1/2, cy1 = y1 + h1/2;
    const cx2 = x2 + w2/2, cy2 = y2 + h2/2;
    const dx = cx2 - cx1;
    const dy = cy2 - cy1;

    const start = intersectRect(cx1, cy1, w1, h1, dx, dy);
    const end   = intersectRect(cx2, cy2, w2, h2, -dx, -dy);
    edge.el.setAttribute('x1', start.x);
    edge.el.setAttribute('y1', start.y);
    edge.el.setAttribute('x2', end.x);
    edge.el.setAttribute('y2', end.y);
  }

  function createEdge(fromId, toId) {
    if (fromId === toId) return;
    if (!boxes.has(fromId) || !boxes.has(toId)) return;
    
    const existingEdge = edges.find(e => e.fromId === fromId && e.toId === toId);
    if (existingEdge) { return; }
    
    const reverseEdge = edges.find(e => e.fromId === toId && e.toId === fromId);
    if (reverseEdge) { 
      alert('Bidirectional edges are not allowed.');
      return;
    }

    dag.addEdge(fromId, toId)
    if (dag.hasCycle()) { 
      alert('Adding this edge will create a cyclic dependency among the launchers.');
      return; 
    }
  
    const line = document.createElementNS('http://www.w3.org/2000/svg', 'line');
    line.classList.add('edge');
    edges_svg.appendChild(line);
    const edge = { fromId, toId, el: line };
    edges.push(edge);
    updateEdgeLine(edge);

    line.addEventListener('click', (e) => {
      e.stopPropagation();
      document.querySelectorAll('.edge.selected').forEach(el => el.classList.remove('selected'));
      document.querySelectorAll('.launcher-item.selected').forEach(el => el.classList.remove('selected'));
      selected_launcher_id = null;

      line.classList.add('selected');
      selected_edge = edge;
    });
  }

  function makeLauncher(row, col, id, title) {
    const url = `${base_launcher_url}/${id}/render_button`;

    $.get(url, function(html) {
      const $launcher = $(`
        <div class="launcher-item" id="launcher_${id}" data-row="${row}" data-col="${col}">
          <div class="launcher-title">${title}</div>
          ${html}
        </div>
      `);

      $('#stage').append($launcher);
      const pos = cellToXY(row, col);
      $launcher.css({ left: pos.x + "px", top: pos.y + "px" });
      const model = { el: $launcher[0], row, col, w: $launcher.outerWidth(), h: $launcher.outerHeight() };
      boxes.set(id, model);
      updateBoxPosition(id, pos.x, pos.y);

      // Pointer / drag events
      $launcher.on('pointerdown', function(e) {
        e.stopPropagation();
        selected_launcher_id = id;
        $('.launcher-item.selected').removeClass('selected');
        $launcher.addClass('selected');

        const start = pointerInStage(e);
        const startX = model.x, startY = model.y;

        $(document).on('pointermove.launcher', function(ev) {
          const p = pointerInStage(ev);
          updateBoxPosition(id, startX + (p.x - start.x), startY + (p.y - start.y));
        });

        $(document).on('pointerup.launcher', function() {
          $(document).off('.launcher');
          const snapped = snapToGrid(model.x, model.y);

          if (isCellOccupied(snapped.row, snapped.col, id)) {
            const revertPos = cellToXY(model.row, model.col);
            updateBoxPosition(id, revertPos.x, revertPos.y);
          } else {
            model.row = snapped.row;
            model.col = snapped.col;
            const finalPos = cellToXY(snapped.row, snapped.col);
            updateBoxPosition(id, finalPos.x, finalPos.y);
            $launcher.attr("data-row", snapped.row).attr("data-col", snapped.col);
          }
        });
      });

      // Connect mode click
      $launcher.on('click', function(e) {
        if (!connect_mode) return;
        e.stopPropagation();
        if (!connect_queue) {
          connect_queue = id;
          $launcher.addClass('connect-queued');
        } else {
          const fromId = connect_queue;
          const toId = id;
          $(`#launcher_${fromId}`).removeClass('connect-queued');
          connect_queue = null;
          createEdge(fromId, toId);
        }
      });
    }, 'html');
  }

  function deleteSelectedLauncher() {
    if (!selected_launcher_id) return;
    dag.removeLauncher(selected_launcher_id);
    const id = selected_launcher_id;
    for (let i = edges.length-1; i>=0; i--) {
      const e = edges[i];
      if (e.fromId===id || e.toId===id) {
        e.el.remove();
        edges.splice(i,1);
      }
    }
    boxes.get(id)?.el.remove();
    boxes.delete(id);
    selected_launcher_id = null;
  }

  function deleteSelectedEdge() {
    if (!selected_edge) return;
    selected_edge.el.remove();
    dag.removeEdge(selected_edge.fromId, selected_edge.toId);
    edges.splice(edges.indexOf(selected_edge), 1);
    selected_edge = null;
  }

  add_launcher_button.addEventListener('click', () => {
    const launcher_id = selected_launcher.value;
    if (!launcher_id) return alert('Please select a launcher');
    const launcher_exists = document.getElementById(`launcher_${launcher_id}`);
    if(launcher_exists) return alert('Launcher already exists, please select a different launcher');

    const title = selected_launcher.options[selected_launcher.selectedIndex].text;
    const spawn = gridSpawn();
    if (spawn) makeLauncher(spawn.row, spawn.col, launcher_id, title);
  });

  connect_launcher_button.addEventListener('click', () => {
    connect_mode = !connect_mode;
    connect_launcher_button.classList.toggle('active', connect_mode);
    connect_launcher_button.setAttribute('aria-pressed', String(connect_mode));
    if (!connect_mode && connect_queue) {
      document.querySelector(`#launcher_${connect_queue}`)?.classList.remove('connect-queued');
      connect_queue = null;
    }
  });

  delete_launcher_button.addEventListener('click', deleteSelectedLauncher);
  delete_edge_button.addEventListener('click', deleteSelectedEdge);

  stage.addEventListener('pointerdown', (e) => {
    if (!e.target.closest('.launcher-item')) {
      selected_launcher_id = null;
      document.querySelectorAll('.launcher-item.selected').forEach(el => el.classList.remove('selected'));
      selected_edge = null;
      document.querySelectorAll('.edge.selected').forEach(el => el.classList.remove('selected'));
    }
  });

  stage.addEventListener('keydown', (e) => {
    if (e.key === 'Delete' || e.key === 'Backspace') {
      e.preventDefault();
      if (selected_launcher_id) {
        deleteSelectedLauncher();
      } else if (selected_edge) {
        deleteSelectedEdge();
      }
    }
    if (e.key === 'Escape' && connect_mode) connect_launcher_button.click();
  });

  const resizeObserver = new ResizeObserver(() => {
    edges_svg.setAttribute('width', stage.offsetWidth);
    edges_svg.setAttribute('height', stage.offsetHeight);
    edges.forEach(updateEdgeLine);
  });
  resizeObserver.observe(stage);

  function init() {
    edges_svg.setAttribute('width', stage.offsetWidth);
    edges_svg.setAttribute('height', stage.offsetHeight);
  }
  init();
})();
