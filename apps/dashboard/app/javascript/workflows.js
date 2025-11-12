import { DAG } from './dag.js';
import { rootPath } from './config.js';

/*
 * Helper Classes to support Drag and Drop UI 
 */

// Handles boxes, edges, auto-save, auto-load and saving to workflow model
class WorkflowState {
  constructor(projectId, workflowId, boxes, edges, dag, pointer, baseUrl) {
    this.projectId = projectId;
    this.workflowId = workflowId;
    this.boxes = boxes;
    this.edges = edges;
    this.dag = dag;
    this.pointer = pointer;
    this.baseUrl = baseUrl;
    this.saveUrl = `${baseUrl}/save`;
    this.submitUrl = `${baseUrl}/submit`;
    this.loadUrl = `${baseUrl}/load`;
    this.STORAGE_KEY = `project_${projectId}_workflow_${workflowId}_state`;
    this.poller = new JobPoller(projectId);
    this.job_hash = {};
  }

  resetWorkflow(e) {
    this.boxes.forEach(b => b.el.remove());
    this.boxes.clear();
    this.edges.forEach(e => e.el.remove());
    this.edges.length = 0;
    this.dag.reset();
    this.pointer.resetZoom();
    this.#clearSession();
    alert('Workflow reset.');
  }

  saveToSession() {
    try {
      sessionStorage.setItem(this.STORAGE_KEY, JSON.stringify(this.#serialize()));
    } catch (err) {
      console.error('Failed to save workflow in session:', err);
    }
  }

  async saveToBackend(submit=false) {
    if (submit) this.job_hash = {}; // This will save a state where the submit call failed in between
    const workflow = this.#serialize();
    console.log('Saving workflow:', workflow);
    try {
      const csrfToken = document.querySelector('meta[name="csrf-token"]').content;

      let url = submit ? this.submitUrl : this.saveUrl;
      const response = await fetch(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken
        },
        body: JSON.stringify(workflow)
      });

      const data = await response.json();
      if (!response.ok) throw new Error(`Server error: ${response.status} message: ${data.message}`);
      alert(data.message);
      if (submit) {
        this.job_hash = data.job_hash;
        await this.#setJobDescription();
        await this.#setupJobPoller();
        this.saveToSession();
      }
    } catch (err) {
      console.error('Error saving workflow:', err);
      alert('Failed to save workflow. Check console for details.');
    }
  }

  async restorePreviousState(makeLauncher, createEdge) {
    const sessionMetadata = await this.#restoreFromSession();
    const backendMetadata = await this.#loadWorkflowFromBackend();
    
    let metadata = null;
    const sessionTs = this.#parseTime(sessionMetadata?.saved_at);
    const backendTs = this.#parseTime(backendMetadata?.saved_at);
    if (sessionTs == null && backendTs == null) {
      console.log('No saved workflow found in session or backend.');
      return;
    } else if (sessionTs < backendTs) {
      metadata = backendMetadata;
      console.log('Restoring workflow from backend metadata.');
    } else {
      metadata = sessionMetadata;
      console.log('Restoring workflow from session metadata.');
    }

    try {
      if (metadata.boxes) {
        await Promise.all(
          metadata.boxes.map(b => makeLauncher(b.row, b.col, b.id, b.title))
        );
      }
      if (metadata.edges) {
        metadata.edges.forEach(e => createEdge(e.from, e.to));
      }
      if (metadata.zoom) {
        this.pointer.zoomRef.value = metadata.zoom;
        this.pointer.applyZoomCb();
      }
      this.job_hash = metadata.job_hash;
      await this.#setJobDescription();
      await this.#setupJobPoller();
      console.info('Workflow restored correctly.');
    } catch (err) {
      console.error('Failed to apply stored workflow:', err);
    }
  }

  #serialize() {
    return {
      boxes: Array.from(this.boxes.values()).map(b => ({
        id: b.id,
        title: b.el.querySelector('.launcher-title-grab')?.textContent?.trim() || '',
        row: b.row,
        col: b.col
      })),
      edges: this.edges.map(e => ({
        from: e.fromBox.id,
        to: e.toBox.id
      })),
      zoom: this.pointer.zoomRef.value,
      job_hash: this.job_hash,
      saved_at: new Date().toISOString()
    };
  }

  #clearSession() {
    sessionStorage.removeItem(this.STORAGE_KEY);
  }

  #parseTime(ts) {
    if (!ts) return null;
    const d = new Date(ts);
    return isNaN(d) ? null : d;
  }

  async #restoreFromSession() {
    const json = sessionStorage.getItem(this.STORAGE_KEY);
    if (!json) return null;
    try {
      const data = JSON.parse(json);
      return data;
    } catch (err) {
      console.error('Failed to restore workflow from session:', err);
      return null;
    }
  }

  async #loadWorkflowFromBackend() {
    try {
      const response = await fetch(this.loadUrl);
      const data = await response.json();
      if (!response.ok) throw new Error(`Server error: ${response.status} message: ${data.message}`);
      return data;
    } catch (err) {
      console.error('Failed to load workflow from backend:', err);
      return null;
    }
  }

  async #setJobDescription() {
    if(!this.job_hash || Object.keys(this.job_hash).length === 0)
      return;

    $.each(this.job_hash, function (launcherId, jobInfo) {
      const $launcher = $(`#launcher_${launcherId}`);

      if ($launcher.length && jobInfo) {
        $launcher.attr({
          "data-job-poller": "true",
          "data-job-id": jobInfo.job_id,
          "data-job-cluster": jobInfo.cluster_id
        });
      }
    });
  }

  async #setupJobPoller() {
    const self = this;
    $('[data-job-poller="true"]').each((_index, ele) => {
      this.poller.pollForJobInfo(ele);
    });
  }
}

// Polling class to update job status
class JobPoller {
  constructor(projectId) {
    this.projectId = projectId;
  }

  jobDetailsPath(cluster, jobId) {
    const baseUrl = rootPath();
    return `${baseUrl}/projects/${this.projectId}/jobs/${cluster}/${jobId}`;
  }
  
  stringToHtml(html) {
    const template = document.createElement('template');
    template.innerHTML = html.trim();
    return template.content.firstChild;
  }

  async pollForJobInfo(element) {
    const cluster = element.dataset['jobCluster'];
    const jobId = element.dataset['jobId'];
    const el = element.jquery ? element[0] : element;
  
    if(cluster === undefined || jobId === undefined){ return; }
  
    const url = this.jobDetailsPath(cluster, jobId);
  
    fetch(url, { headers: { Accept: "text/vnd.turbo-stream.html" } })
      .then(response => response.ok ? Promise.resolve(response) : Promise.reject(response.text()))
      .then((r) => r.text())
      .then((html) => {
        const responseHtml = this.stringToHtml(html);
        const jobState = responseHtml.dataset['jobNativeState'];

        el.classList.remove('running', 'completed', 'failed', 'pending');
        if( jobState === 'COMPLETED' ) {
          el.classList.add('completed');
        } else if ( jobState === 'FAILED' || jobState === 'CANCELLED' || jobState === 'TIMEOUT' ) {
          el.classList.add('failed');
        } else if ( jobState === 'RUNNING' || jobState === 'COMPLETING' ) {
          el.classList.add('running');
        } else if ( jobState === 'PENDING' || jobState === 'QUEUED' || jobState === 'SUSPENDED' ) {
          el.classList.add('pending');
        }
        
        console.log(`Job ${jobId} on cluster ${cluster} native state: ${jobState}`);
        return { jobState, html };
      })
      .then(({jobState, html}) => {
        const endStates = ['COMPLETED', 'FAILED', 'CANCELLED', 'TIMEOUT', 'undefined'];
        if(!endStates.includes(jobState)) {
          setTimeout(() => this.pollForJobInfo(element), 30000);
        } else {
          element.dataset.jobPoller = "false";
        }
        
        if (jobState !== 'undefined' && html) {
          // This needs not to be persistent with the session storage which we save to backend
          const launcherId = el.id.replace('launcher_', '');
          if (!launcherId) return;
          const jobSessionKey = `job_info_html_${launcherId}`;
          sessionStorage.setItem(jobSessionKey, html);

          const infoBtn = document.getElementById(`job_info_${launcherId}`);
          if (infoBtn) {
            infoBtn.disabled = false;
            infoBtn.classList.remove('disabled');

            if (!infoBtn.dataset.listenerAttached) {
              infoBtn.addEventListener('click', () => {
                const html = sessionStorage.getItem(jobSessionKey);
                this.showJobInfoOverlay(html);
              });
              infoBtn.dataset.listenerAttached = "true";
            }
          }
        }
      })
      .catch((err) => {
        console.log('Cannot not retrieve job info due to error:');
        console.log(err);
      });
  }

  showJobInfoOverlay(html) {
    const existing = document.getElementById('job-info-overlay');
    if (existing) existing.remove();

    const overlay = document.createElement('div');
    overlay.id = 'job-info-overlay';
    const content = document.createElement('div');
    content.className = 'job-info-content';

    const template = this.stringToHtml(html).querySelector('template');
    const fragment = template.content.cloneNode(true);
    const collapseDiv = fragment.querySelector('.collapse');
    if (collapseDiv) { // So save one extra click from user
      collapseDiv.classList.remove('collapse');
      collapseDiv.classList.add('show');
    }
    content.appendChild(fragment);

    const closeBtn = document.createElement('button');
    closeBtn.className = 'job-info-close';
    closeBtn.textContent = '×';
    closeBtn.addEventListener('click', () => overlay.remove());

    overlay.addEventListener('click', (e) => {
      if (e.target === overlay) overlay.remove();
    });

    content.prepend(closeBtn);
    overlay.appendChild(content);
    const stage = document.getElementById('workspace-wrapper');
    stage.appendChild(overlay);
  }
}

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
  constructor(pointer, boxes, edges, gridCols, gridRows, cell_w, cell_h, halfGap, saveToSession) {
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
    this.workflowSaveCb = saveToSession;

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
    this.workflowSaveCb();
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
(async () => {
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
  const submitWorkflowButton = document.getElementById('btn-submit-workflow');
  const resetWorkflowButton = document.getElementById('btn-reset-workflow');
  const saveWorkflowButton = document.getElementById('btn-save-workflow');
  const projectId = document.getElementById('project-id').value;
  const workflowId = document.getElementById('workflow-id').value;
  const baseWorkflowUrl = document.getElementById('base-workflow-url').value;
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
  const workflowState = new WorkflowState(projectId, workflowId, boxes, edges, dag, pointer, baseWorkflowUrl);
  const workflowSaveCb = () => workflowState.saveToSession();
  const drag = new DragController(pointer, boxes, edges, gridCols, gridRows, cell_w, cell_h, halfGap, workflowSaveCb);

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
    return new Promise((resolve, reject) => {
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
            workflowSaveCb();
          }
        });

        resolve();
      }).fail(function() {
        alert('Failed to load launcher HTML. Please try again.');
        reject();
      });
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
    workflowSaveCb();
  }

  function deleteSelectedEdge() {
    if (!selectedEdge) return;
    selectedEdge.el.remove();
    dag.removeEdge(selectedEdge.fromBox.id, selectedEdge.toBox.id);
    edges.splice(edges.indexOf(selectedEdge), 1);
    selectedEdge = null;
    workflowSaveCb();
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
        workflowSaveCb();
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

  submitWorkflowButton.addEventListener('click', debounce(async () => {
    await workflowState.saveToBackend(true);
  }, 300));
  resetWorkflowButton.addEventListener('click', debounce(e => workflowState.resetWorkflow(e), 300));
  saveWorkflowButton.addEventListener('click', debounce(() => workflowState.saveToBackend(), 300));

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

  await workflowState.restorePreviousState(makeLauncher, createEdge);
  init();
})();
