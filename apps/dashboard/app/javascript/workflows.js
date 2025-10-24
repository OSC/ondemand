import { DAG } from './dag.js';

/*
 * Helper Classes to support Drag and Drop UI 
 */

// Box represents a draggable launcher box
class Box {
  constructor(id, el, row, col, w, h) {
    this.id = id;
    this.el = el;
    this.row = row;
    this.col = col;
    this.x = 0;
    this.y = 0;
    this.w = w;
    this.h = h;
  }

  moveTo(x, y) {
    this.x = x;
    this.y = y;
    this.el.style.transform = `translate(${x}px, ${y}px)`;
  }
}

// Edge represents a connection between two launcher boxes
class Edge {
  constructor(fromBox, toBox, el, clickEl) {
    this.fromBox = fromBox;
    this.toBox = toBox;
    this.el = el;
    this.clickEl = clickEl
  }

  intersectRect(cx, cy, w, h, dx, dy) {
    const absDx = Math.abs(dx);
    const absDy = Math.abs(dy);
    let scale = 0.5 / Math.max(absDx / w, absDy / h);
    scale = Math.min(scale, 1);
    return { x: cx + dx * scale, y: cy + dy * scale };
  }

  update() {
    const { fromBox, toBox } = this;
    const cx1 = fromBox.x + fromBox.w / 2, cy1 = fromBox.y + fromBox.h / 2;
    const cx2 = toBox.x + toBox.w / 2, cy2 = toBox.y + toBox.h / 2;
    const dx = cx2 - cx1, dy = cy2 - cy1;
    const start = this.intersectRect(cx1, cy1, fromBox.w, fromBox.h, dx, dy);
    const end = this.intersectRect(cx2, cy2, toBox.w, toBox.h, -dx, -dy);

    this.el.setAttribute('x1', start.x);
    this.el.setAttribute('y1', start.y);
    this.el.setAttribute('x2', end.x);
    this.el.setAttribute('y2', end.y);
    this.clickEl.setAttribute('x1', start.x);
    this.clickEl.setAttribute('y1', start.y);
    this.clickEl.setAttribute('x2', end.x);
    this.clickEl.setAttribute('y2', end.y);
  }
}

// Pointer tracks mouse on screen and translates to stage coordinates
class Pointer {
  constructor(stage, zoomRef, step, max, min, applyZoomCb) {
    this.stage = stage;
    this.zoomRef = zoomRef;
    this.step = step;
    this.max = max;
    this.min = min;
    this.applyZoomCb = applyZoomCb;
    this.x = 0;
    this.y = 0;
  }

  update(e) {
    const r = this.stage.getBoundingClientRect();
    const clientX = e.clientX ?? e.touches?.[0].clientX;
    const clientY = e.clientY ?? e.touches?.[0].clientY;
    this.x = (clientX - r.left) / this.zoomRef.value;
    this.y = (clientY - r.top) / this.zoomRef.value;
  }

  pos() {
    return { x: this.x, y: this.y };
  }

  zoomIn() {
    this.zoomRef.value = Math.min(this.zoomRef.value + this.step, this.max);
    this.applyZoomCb();
  }

  zoomOut() {
    this.zoomRef.value = Math.max(this.zoomRef.value - this.step, this.min);
    this.applyZoomCb();
  }

  resetZoom() {
    this.zoomRef.value = 1;
    this.applyZoomCb();
  }

  handleWheel(e) {
    if (e.ctrlKey) {
      e.preventDefault();
      if (e.deltaY < 0) {
        this.zoomIn();
      } else {
        this.zoomOut();
      }
    }
  }
}

// DragController manages dragging of launcher boxes
class DragController {
  constructor(pointer, boxes, edges, gridCols, gridRows, cell_w, cell_h, halfGap) {
    this.pointer = pointer;
    this.boxes = boxes;
    this.edges = edges;
    this.gridCols = gridCols;
    this.gridRows = gridRows;
    this.cell_w = cell_w;
    this.cell_h = cell_h;
    this.halfGap = halfGap;
    this.dragging = null;
    this.start = null;

    document.addEventListener('pointermove', e => this.onMove(e));
    document.addEventListener('pointerup', e => this.onUp(e));
  }

  update(gridCols, gridRows) {
    this.gridCols = gridCols;
    this.gridRows = gridRows;
  }

  beginDrag(box) {
    this.start = {
      px: this.pointer.x,
      py: this.pointer.y,
      x: box.x,
      y: box.y
    };
    this.dragging = box;
  }

  onMove(e) {
    if (!this.dragging) return;
    this.pointer.update(e);
    const dx = this.pointer.x - this.start.px;
    const dy = this.pointer.y - this.start.py;
    this.updateBoxPosition(this.dragging, this.start.x + dx, this.start.y + dy);
  }

  onUp(e) {
    if (!this.dragging) return;
    const box = this.dragging;
    const snapped = this.snapToGrid(box.x, box.y);

    if (this.isCellOccupied(snapped.row, snapped.col, box.id)) {
      const revertPos = this.cellToXY(box.row, box.col);
      this.updateBoxPosition(box, revertPos.x, revertPos.y);
    } else {
      box.row = snapped.row;
      box.col = snapped.col;
      const finalPos = this.cellToXY(snapped.row, snapped.col);
      this.updateBoxPosition(box, finalPos.x, finalPos.y);
      box.el.setAttribute('data-row', snapped.row);
      box.el.setAttribute('data-col', snapped.col);
    }

    this.dragging = null;
    this.start = null;
  }

  snapToGrid(x, y) {
    const col = Math.max(1, Math.min(this.gridCols, Math.round((x - this.halfGap) / this.cell_w) + 1));
    const row = Math.max(1, Math.min(this.gridRows, Math.round((y - this.halfGap) / this.cell_h) + 1));
    return { row, col };
  }

  cellToXY(row, col) {
    return {
      x: (col - 1) * this.cell_w + this.halfGap,
      y: (row - 1) * this.cell_h + this.halfGap
    };
  }

  isCellOccupied(row, col, excludeId = null) {
    for (const [id, box] of this.boxes.entries()) {
      if (id !== excludeId && box.row === row && box.col === col) {
        return true;
      }
    }
    return false;
  }

  updateBoxPosition(box, x, y) {
    box.moveTo(x, y);
    this.edges.forEach(edge => {
      if (edge.fromBox === box || edge.toBox === box) {
        edge.update();
      }
    });
  }
}

/*
 * Immediately Invoked Function Expression (IIFE) to encapsulate the workflow logic
*/
(() => {
  // Document elements
  const workspace = document.getElementById('workspace');
  const stage = document.getElementById('stage');
  const edgesSvg = document.getElementById('edges');
  const addLauncherButton = document.getElementById('btn-add');
  const connectLauncherButton = document.getElementById('btn-connect');
  const deleteLauncherButton = document.getElementById('btn-delete-launcher');
  const deleteEdgeButton = document.getElementById('btn-delete-edge');
  const zoomInButton = document.getElementById('zoom-in');
  const zoomOutButton = document.getElementById('zoom-out');
  const zoomResetButton = document.getElementById('zoom-reset');
  const selectedLauncher = document.getElementById('select_launcher');
  const baseLauncherUrl = document.getElementById('base-launcher-url').value;
  const styles = getComputedStyle(document.documentElement);
  const stageZoom = document.getElementById('stage-zoom');

  // State variables and constants
  const zoomState = {value: 1};
  const cell_w = parseInt(styles.getPropertyValue('--cell_w')) + parseInt(styles.getPropertyValue('--gap'));
  const cell_h = parseInt(styles.getPropertyValue('--cell_h')) + parseInt(styles.getPropertyValue('--gap'));
  const halfGap = parseInt(styles.getPropertyValue('--gap')) / 2;
  const zoomMax = 2.0;
  const zoomMin = 0.1; // 0.125 needed for 32x32 grid to fit
  const zoomStep = 0.1;
  const fillRatioExpand = 0.40;
  const fillRatioShrink = 0.1; // 8x smaller than expand ratio
  let selectedLauncherId = null;
  let selectedEdge = null;
  let connectMode = false;
  let connectQueue = null;
  let gridExpanded = false;
  let gridCols = parseInt(styles.getPropertyValue('--grid_cols'));
  let gridRows = parseInt(styles.getPropertyValue('--grid_rows'));

  // Class instances
  const dag = new DAG();
  const boxes = new Map();
  const edges = [];
  const pointer = new Pointer(stage, zoomState, zoomStep, zoomMax, zoomMin, applyZoom);
  const drag = new DragController(pointer, boxes, edges, gridCols, gridRows, cell_w, cell_h, halfGap);

  function applyZoom() {
    stageZoom.style.transform = `scale(${zoomState.value})`;
    edges.forEach(edge => edge.update());
    zoomResetButton.textContent = `${Math.round(zoomState.value * 100)}%`;
  }

  function gridSpawn() {
    for (let r = 1; r <= gridRows; r++) {
      for (let c = 1; c <= gridCols; c++) {
        let occupied = false;
        for (let box of boxes.values()) {
          if (box.row === r && box.col === c) {
            occupied = true;
            break;
          }
        }
        if (!occupied) return { row: r, col: c };
      }
    }
    alert('No empty grid cells available!');
    return null;
  }

  // No launcher box should be outside [1...row][1..col] to resize
  // else will lead to launchers left outside the workflow-stage
  function checkIfBoxOutside(newRows, newCols) {
    for (const box of boxes.values()) {
      if (box.row > newRows || box.col > newCols) {
        return true;
      }
    }
    return false;
  }

  // Maximum we support 1024 launchers (32x32 grid)
  function changeGridIfNeeded() {
    const totalCells = gridCols * gridRows;
    const usedCells = boxes.size;
    const fillRatio = usedCells / totalCells;

    if (fillRatio >= fillRatioExpand && !gridExpanded) {
      gridCols *= 2;
      gridRows *= 2;
      drag.update(gridCols, gridRows);

      stage.style.gridTemplateColumns = `repeat(${gridCols}, ${cell_w}px)`;
      stage.style.gridTemplateRows = `repeat(${gridRows}, ${cell_h}px)`;
      stage.style.minWidth = `${gridCols * cell_w}px`;
      stage.style.minHeight = `${gridRows * cell_h}px`;

      edges.forEach(edge => edge.update());
      gridExpanded = true;
    } else if (fillRatio < fillRatioShrink && gridExpanded) { 
      if (checkIfBoxOutside(gridRows/2, gridCols/2)) return;
      gridCols = Math.floor(gridCols / 2);
      gridRows = Math.floor(gridRows / 2);
      drag.update(gridCols, gridRows);

      stage.style.gridTemplateColumns = `repeat(${gridCols}, ${cell_w}px)`;
      stage.style.gridTemplateRows = `repeat(${gridRows}, ${cell_h}px)`;
      stage.style.minWidth = `${gridCols * cell_w}px`;
      stage.style.minHeight = `${gridRows * cell_h}px`;

      edges.forEach(edge => edge.update());
      gridExpanded = false;
    }
  }

  function createEdge(fromId, toId) {
    console.log(  `Creating edge from ${fromId} to ${toId}`);
    if (fromId === toId) return;
    if (!boxes.has(fromId) || !boxes.has(toId)) return;

    const existingEdge = edges.find(e => e.fromBox.id === fromId && e.toBox.id === toId);
    if (existingEdge) return;

    const reverseEdge = edges.find(e => e.fromBox.id === toId && e.toBox.id === fromId);
    if (reverseEdge) {
      alert('Bidirectional edges are not allowed.');
      return;
    }

    dag.addEdge(fromId, toId);
    if (dag.hasCycle()) {
      dag.removeEdge(fromId, toId);
      alert('Adding this edge will create a cyclic dependency among the launchers.');
      return;
    }

    const clickArea = document.createElementNS('http://www.w3.org/2000/svg', 'line');
    clickArea.classList.add('edge', 'click-area');
    edgesSvg.appendChild(clickArea);

    const line = document.createElementNS('http://www.w3.org/2000/svg', 'line');
    line.classList.add('edge');
    edgesSvg.appendChild(line);
    
    const edge = new Edge(boxes.get(fromId), boxes.get(toId), line, clickArea);
    edges.push(edge);
    edge.update();

    clickArea.addEventListener('click', (e) => {
      e.stopPropagation();
      document.querySelectorAll('.edge.selected').forEach(el => el.classList.remove('selected'));
      document.querySelectorAll('.launcher-box.selected').forEach(el => el.classList.remove('selected'));
      selectedLauncherId = null;

      line.classList.add('selected');
      selectedEdge = edge;
    });
  }

  function makeLauncher(row, col, id, title) {
    const url = `${baseLauncherUrl}/${id}/render_button`;
    $.get(url, function(html) {
      const $launcher = $(`
        <div class='launcher-box' id='launcher_${id}' data-row='${row}' data-col='${col}'>
          <div class='row'>
            <div class='col launcher-title-grab'>${title}</div>
          </div>
          ${html}
        </div>
      `);

      $('#stage').append($launcher);
      const pos = drag.cellToXY(row, col);
      $launcher.css({ transform: `translate(${pos.x}px, ${pos.y}px)` });
      const box = new Box(id, $launcher[0], row, col, $launcher.outerWidth(), $launcher.outerHeight());
      boxes.set(id, box);
      drag.updateBoxPosition(box, pos.x, pos.y);

      // Pointer / drag events
      $launcher.on('pointerdown', function(e) {
        e.stopPropagation();
        selectedLauncherId = id;
        $('.launcher-box.selected').removeClass('selected');
        $launcher.addClass('selected');
        pointer.update(e);
        drag.beginDrag(box);
      });

      // Connect mode click
      $launcher.on('click', function(e) {
        if (!connectMode) return;
        e.stopPropagation();
        if (!connectQueue) {
          connectQueue = id;
          $launcher.addClass('connect-queued');
        } else {
          const fromId = connectQueue;
          const toId = id;
          $(`#launcher_${fromId}`).removeClass('connect-queued');
          connectQueue = null;
          createEdge(fromId, toId);
        }
      });
    }).fail(function() {
      alert('Failed to load launcher HTML. Please try again.');
    });
  }

  function deleteSelectedLauncher() {
    if (!selectedLauncherId) return;
    dag.removeLauncher(selectedLauncherId);
    for (let i = edges.length - 1; i >= 0; i--) {
      const e = edges[i];
      if (e.fromBox.id === selectedLauncherId || e.toBox.id === selectedLauncherId) {
        e.el.remove();
        edges.splice(i, 1);
      }
    }
    boxes.get(selectedLauncherId)?.el.remove();
    boxes.delete(selectedLauncherId);
    selectedLauncherId = null;
    changeGridIfNeeded();
  }

  function deleteSelectedEdge() {
    if (!selectedEdge) return;
    selectedEdge.el.remove();
    dag.removeEdge(selectedEdge.fromBox.id, selectedEdge.toBox.id);
    edges.splice(edges.indexOf(selectedEdge), 1);
    selectedEdge = null;
  }

  // This helps to bounce rapid button clicks ie. accidental double clicks
  function debounce(fn, delay = 300) {
    let timeout;
    return function (...args) {
      if (timeout) return;
      fn.apply(this, args);
      timeout = setTimeout(() => (timeout = null), delay);
    };
  }

  async function handleAddLauncherClick() {
    if(addLauncherButton.disabled) return;
    addLauncherButton.disabled = true;
    addLauncherButton.classList.add('active');
    setTimeout(() => addLauncherButton.classList.remove('active'), 150);

    try {
      const launcherId = selectedLauncher.value;
      if (!launcherId) return alert('Please select a launcher');
      const launcherExists = document.getElementById(`launcher_${launcherId}`);
      if (launcherExists) return alert('Launcher already exists, please select a different launcher');

      const title = selectedLauncher.options[selectedLauncher.selectedIndex].text;
      const spawn = gridSpawn();
      if (spawn) {
        await makeLauncher(spawn.row, spawn.col, launcherId, title);
        changeGridIfNeeded(); 
      }
    } finally {
      addLauncherButton.disabled = false;
    }
  }

  addLauncherButton.addEventListener('click', debounce(handleAddLauncherClick, 300));

  connectLauncherButton.addEventListener('click', () => {
    connectMode = !connectMode;
    connectLauncherButton.classList.toggle('active', connectMode);
    connectLauncherButton.setAttribute('aria-pressed', String(connectMode));
    if (!connectMode && connectQueue) {
      document.querySelector(`#launcher_${connectQueue}`)?.classList.remove('connect-queued');
      connectQueue = null;
    }
  });

  deleteLauncherButton.addEventListener('click', deleteSelectedLauncher);
  deleteEdgeButton.addEventListener('click', deleteSelectedEdge);

  zoomInButton.addEventListener('click', () => { pointer.zoomIn(); });
  zoomOutButton.addEventListener('click', () => { pointer.zoomOut(); });
  zoomResetButton.addEventListener('click', () => { pointer.resetZoom();});

  workspace.addEventListener('pointermove', e => pointer.update(e));
  workspace.addEventListener('touchmove', e => pointer.update(e));
  workspace.addEventListener('wheel', e => pointer.handleWheel(e), { passive: false });

  stage.addEventListener('pointerdown', (e) => {
    if (!e.target.closest('.launcher-box')) {
      selectedLauncherId = null;
      document.querySelectorAll('.launcher-box.selected').forEach(el => el.classList.remove('selected'));
      selectedEdge = null;
      document.querySelectorAll('.edge.selected').forEach(el => el.classList.remove('selected'));
    }
  });

  stage.addEventListener('keydown', (e) => {
    if (e.key === 'Delete' || e.key === 'Backspace') {
      e.preventDefault();
      if (selectedLauncherId) {
        deleteSelectedLauncher();
      } else if (selectedEdge) {
        deleteSelectedEdge();
      }
    }
    if (e.key === 'Escape' && connectMode) connectLauncherButton.click();
  });

  const resizeObserver = new ResizeObserver(() => {
    edgesSvg.setAttribute('width', stage.offsetWidth);
    edgesSvg.setAttribute('height', stage.offsetHeight);
    edges.forEach(edge => edge.update());
  });
  resizeObserver.observe(stage);

  function init() {
    edgesSvg.setAttribute('width', stage.offsetWidth);
    edgesSvg.setAttribute('height', stage.offsetHeight);
  }
  init();
})();
