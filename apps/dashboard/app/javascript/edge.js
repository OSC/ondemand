// Orthogonal Edge System for Workflow DAG
// Draw.io–style edges with unlimited user-created bends.
//
// Handle types:
//   ● Corner handle  (solid)       – sits at each bend, drag to move it
//   ○ Midpoint handle (translucent) – sits at middle of each segment,
//                                     drag to split that segment into a new bend
//
// Ports: right side = output (edge start), left side = input (edge end)

const SVG_NS = 'http://www.w3.org/2000/svg';

/* ================================================================== */
/*  OrthogonalEdge                                                     */
/* ================================================================== */

export class OrthogonalEdge {
  /**
   * @param {Object}     fromBox   – source Box instance
   * @param {Object}     toBox     – target Box instance
   * @param {SVGElement} svgGroup  – <g> element that holds all edge visuals
   */
  constructor(fromBox, toBox, svgGroup) {
    this.fromBox = fromBox;
    this.toBox   = toBox;
    this.group   = svgGroup;

    // User-created bend points (absolute coords).
    // Empty by default → auto-routed 3-segment path.
    this.bends = [];

    // SVG elements
    this.pathEl      = this._makePath('edge orthogonal-edge');
    this.clickAreaEl = this._makePath('edge click-area orthogonal-edge');

    // Container for dynamic handles (rebuilt on every update)
    this.handleGroup = document.createElementNS(SVG_NS, 'g');
    this.handleGroup.classList.add('edge-handles');

    this.group.appendChild(this.clickAreaEl);
    this.group.appendChild(this.pathEl);
    this.group.appendChild(this.handleGroup);

    // Cache for current waypoints (includes start/end + bends)
    this._waypoints = [];

    // Cache previous port positions for delta-based box move updates
    this._prevFromPort = this._fromPort();
    this._prevToPort   = this._toPort();

    // Once the user has interacted with bends, empty bends = straight line
    this._userEdited = false;
  }

  /* ------------------------------------------------------------------ */
  /*  Public API                                                         */
  /* ------------------------------------------------------------------ */

  /** Recalculate route, redraw path, rebuild handles. */
  update() {
    this._waypoints = this._computeRoute();
    const d = this._pointsToPathD(this._waypoints);
    this.pathEl.setAttribute('d', d);
    this.clickAreaEl.setAttribute('d', d);
    this._rebuildHandles();
  }

  /** Remove all SVG elements from the DOM. */
  remove() {
    this.group.remove();
  }

  /**
   * Called when a connected box is dragged. Instead of recomputing the
   * entire route, only adjusts the segment closest to the moved box's
   * port — keeping the rest of the edge shape intact.
   *
   * If no user bends exist, falls back to full update().
   */
  updateForBoxMove(box) {
    if (this.bends.length === 0) {
      this.update();
      return;
    }

    if (box === this.fromBox) {
      // The source box moved — adjust the first bend to stay connected.
      // Keep the first bend's axis that is NOT shared with the port,
      // and update the shared axis so the segment stays orthogonal.
      const port = this._fromPort();
      const bend = this.bends[0];

      // If first segment was horizontal (same Y), keep bend.x, update bend.y
      // If first segment was vertical (same X), keep bend.y, update bend.x
      // Otherwise just track the port delta
      if (Math.abs(bend.y - this._prevFromPort.y) < 1) {
        bend.y = port.y;
      } else if (Math.abs(bend.x - this._prevFromPort.x) < 1) {
        bend.x = port.x;
      } else {
        // Diagonal / free bend — apply the delta
        const dx = port.x - this._prevFromPort.x;
        const dy = port.y - this._prevFromPort.y;
        bend.x += dx;
        bend.y += dy;
      }
    }

    if (box === this.toBox) {
      // The target box moved — adjust the last bend.
      const port = this._toPort();
      const bend = this.bends[this.bends.length - 1];

      if (Math.abs(bend.y - this._prevToPort.y) < 1) {
        bend.y = port.y;
      } else if (Math.abs(bend.x - this._prevToPort.x) < 1) {
        bend.x = port.x;
      } else {
        const dx = port.x - this._prevToPort.x;
        const dy = port.y - this._prevToPort.y;
        bend.x += dx;
        bend.y += dy;
      }
    }

    this._savePorts();
    this.update();
  }

  /** Cache current port positions for delta calculation on next move. */
  _savePorts() {
    this._prevFromPort = this._fromPort();
    this._prevToPort   = this._toPort();
  }

  /** Reset all user bends so the edge auto-routes again. */
  resetRoute() {
    this.bends = [];
    this._userEdited = false;
    this.update();
  }

  /** Serialize bend data for save/restore. */
  serializeBends() {
    return this.bends.map(b => ({ x: b.x, y: b.y }));
  }

  /** Restore bend data from saved state. */
  restoreBends(arr) {
    if (Array.isArray(arr)) {
      this.bends = arr.map(b => ({ x: b.x, y: b.y }));
    }
  }

  /* ------------------------------------------------------------------ */
  /*  Port helpers                                                       */
  /* ------------------------------------------------------------------ */

  _fromPort() {
    return {
      x: this.fromBox.x + this.fromBox.w,
      y: this.fromBox.y + this.fromBox.h / 2
    };
  }

  _toPort() {
    return {
      x: this.toBox.x,
      y: this.toBox.y + this.toBox.h / 2
    };
  }

  /* ------------------------------------------------------------------ */
  /*  Route computation                                                  */
  /* ------------------------------------------------------------------ */

  /**
   * Build the full waypoint array: [startPort, ...bends, endPort]
   *
   * If user has added bends, use them directly.
   * Otherwise auto-route with a default orthogonal path.
   */
  _computeRoute() {
    const start = this._fromPort();
    const end   = this._toPort();

    if (this.bends.length > 0) {
      return [start, ...this.bends, end];
    }

    // User removed all bends → straight line
    if (this._userEdited) {
      return [start, end];
    }

    // Auto-route
    const MIN_STUB = 30;

    if (end.x - start.x > MIN_STUB * 2) {
      const midX = (start.x + end.x) / 2;
      return [
        start,
        { x: midX, y: start.y },
        { x: midX, y: end.y },
        end
      ];
    }

    // Wrap-around when target is left of source
    const offsetRight = start.x + MIN_STUB;
    const offsetLeft  = end.x - MIN_STUB;
    const boxPadding  = 40;
    const wrapY = (start.y <= end.y)
      ? Math.min(this.fromBox.y, this.toBox.y) - boxPadding
      : Math.max(this.fromBox.y + this.fromBox.h, this.toBox.y + this.toBox.h) + boxPadding;

    return [
      start,
      { x: offsetRight, y: start.y },
      { x: offsetRight, y: wrapY },
      { x: offsetLeft,  y: wrapY },
      { x: offsetLeft,  y: end.y },
      end
    ];
  }

  /* ------------------------------------------------------------------ */
  /*  SVG path                                                           */
  /* ------------------------------------------------------------------ */

  _pointsToPathD(points) {
    if (points.length < 2) return '';

    const RADIUS = 6;
    let d = `M ${points[0].x} ${points[0].y}`;

    for (let i = 1; i < points.length - 1; i++) {
      const prev = points[i - 1];
      const curr = points[i];
      const next = points[i + 1];

      const dx1 = curr.x - prev.x, dy1 = curr.y - prev.y;
      const dx2 = next.x - curr.x, dy2 = next.y - curr.y;
      const len1 = Math.hypot(dx1, dy1);
      const len2 = Math.hypot(dx2, dy2);
      const r = Math.min(RADIUS, len1 / 2, len2 / 2);

      if (r < 1 || len1 === 0 || len2 === 0) {
        d += ` L ${curr.x} ${curr.y}`;
        continue;
      }

      d += ` L ${curr.x - (dx1 / len1) * r} ${curr.y - (dy1 / len1) * r}`;
      d += ` Q ${curr.x} ${curr.y} ${curr.x + (dx2 / len2) * r} ${curr.y + (dy2 / len2) * r}`;
    }

    d += ` L ${points[points.length - 1].x} ${points[points.length - 1].y}`;
    return d;
  }

  _makePath(className) {
    const path = document.createElementNS(SVG_NS, 'path');
    path.setAttribute('class', className);
    path.setAttribute('fill', 'none');
    return path;
  }

  /* ------------------------------------------------------------------ */
  /*  Handles                                                            */
  /* ------------------------------------------------------------------ */

  /**
   * Clear and recreate all handles from current waypoints.
   *
   * For N waypoints we place:
   *   - (N-2) corner handles  at waypoints[1 .. N-2]  (the bends)
   *   - (N-1) midpoint handles at the center of each segment
   */
  _rebuildHandles() {
    // Remove old
    while (this.handleGroup.firstChild) {
      this.handleGroup.removeChild(this.handleGroup.firstChild);
    }

    const pts = this._waypoints;
    if (pts.length < 2) return;

    // Corner handles at each interior waypoint (the bends)
    for (let i = 1; i < pts.length - 1; i++) {
      this._createCornerHandle(pts[i], i - 1);   // bendIndex = i-1
    }

    // Midpoint handles at the center of every segment
    for (let i = 0; i < pts.length - 1; i++) {
      const mid = {
        x: (pts[i].x + pts[i + 1].x) / 2,
        y: (pts[i].y + pts[i + 1].y) / 2
      };
      this._createMidpointHandle(mid, i);         // segIndex = i
    }
  }

  /* ---------- Corner handle (drag to move an existing bend) ---------- */

  _createCornerHandle(pt, bendIndex) {
    const c = document.createElementNS(SVG_NS, 'circle');
    c.setAttribute('cx', pt.x);
    c.setAttribute('cy', pt.y);
    c.setAttribute('r', 6);
    c.setAttribute('class', 'edge-handle corner-handle');
    this.handleGroup.appendChild(c);

    c.addEventListener('pointerdown', (e) => {
      e.stopPropagation();
      e.preventDefault();
      c.classList.add('dragging');

      this._promoteAutoBends();

      const onMove = (ev) => {
        const pos = this._clientToStage(ev);
        this.bends[bendIndex] = this._snapOrtho(pos, bendIndex);
        this.update();
      };

      const onUp = () => {
        c.classList.remove('dragging');
        document.removeEventListener('pointermove', onMove);
        document.removeEventListener('pointerup', onUp);

        this._tryEliminate(bendIndex);
        this.update();
      };

      document.addEventListener('pointermove', onMove);
      document.addEventListener('pointerup', onUp);
    });
  }

  /* ---------- Midpoint handle (drag to create a new bend) ---------- */

  _createMidpointHandle(pt, segIndex) {
    const c = document.createElementNS(SVG_NS, 'circle');
    c.setAttribute('cx', pt.x);
    c.setAttribute('cy', pt.y);
    c.setAttribute('r', 5);
    c.setAttribute('class', 'edge-handle midpoint-handle');
    this.handleGroup.appendChild(c);

    c.addEventListener('pointerdown', (e) => {
      e.stopPropagation();
      e.preventDefault();
      c.classList.add('dragging');

      this._promoteAutoBends();

      // Insert a new bend at the midpoint of this segment.
      //
      // segIndex maps to bends[] insertion point:
      //   segment 0 = start→bend[0]         → splice at 0
      //   segment 1 = bend[0]→bend[1]       → splice at 1
      //   segment k = bend[k-1]→bend[k]/end → splice at k
      const insertAt = segIndex;
      this.bends.splice(insertAt, 0, { x: pt.x, y: pt.y });
      this.update();

      // After update(), the inserted bend is at bends[insertAt].
      // We keep tracking it by its fixed index.
      const onMove = (ev) => {
        const pos = this._clientToStage(ev);
        this.bends[insertAt] = this._snapOrtho(pos, insertAt);
        this.update();
      };

      const onUp = () => {
        c.classList.remove('dragging');
        document.removeEventListener('pointermove', onMove);
        document.removeEventListener('pointerup', onUp);

        // Eliminate bend if dropped close to the midpoint of its neighbours
        this._tryEliminate(insertAt);
        this.update();
      };

      document.addEventListener('pointermove', onMove);
      document.addEventListener('pointerup', onUp);
    });
  }

  /* ------------------------------------------------------------------ */
  /*  Utilities                                                          */
  /* ------------------------------------------------------------------ */


	/**
		* Remove bend at index if it sits close to the line between its
		* two neighbours (i.e. user dragged it back to the segment center).
		*/
	/**
	 * Remove bend if it sits close to the straight line between its
	 * two neighbours. Uses perpendicular distance to the line segment,
	 * so the user just needs to drag the corner roughly back onto the
	 * line — no need to hit the exact midpoint.
	 */
	_tryEliminate(bendIndex) {
		if (bendIndex < 0 || bendIndex >= this.bends.length) return;

		// Recompute waypoints so indices are fresh after any prior splices
		const pts = this._computeRoute();
		const wi = bendIndex + 1;  // waypoint index (0 = start port)
		if (wi < 1 || wi >= pts.length - 1) return;

		const prev = pts[wi - 1];
		const curr = this.bends[bendIndex];
		const next = pts[wi + 1];

		const dist = this._pointToSegmentDist(curr, prev, next);

		if (dist < 15) {
			this.bends.splice(bendIndex, 1);
		}
	}

	/**
	 * Perpendicular distance from point P to line segment AB.
	 */
	_pointToSegmentDist(p, a, b) {
		const dx = b.x - a.x;
		const dy = b.y - a.y;
		const lenSq = dx * dx + dy * dy;

		if (lenSq === 0) return Math.hypot(p.x - a.x, p.y - a.y);

		// Project P onto AB, clamped to [0,1]
		const t = Math.max(0, Math.min(1, ((p.x - a.x) * dx + (p.y - a.y) * dy) / lenSq));
		const projX = a.x + t * dx;
		const projY = a.y + t * dy;

		return Math.hypot(p.x - projX, p.y - projY);
	}

  /**
   * Snap a dragged bend to 90° alignment with its neighbours.
   * If the bend's X or Y is within threshold of a neighbour's,
   * lock it so the segment becomes perfectly horizontal or vertical.
   */
  _snapOrtho(pos, bendIndex) {
    const SNAP_THRESHOLD = 12;
    let { x, y } = pos;

    const start = this._fromPort();
    const end   = this._toPort();
    const prev  = bendIndex > 0 ? this.bends[bendIndex - 1] : start;
    const next  = bendIndex < this.bends.length - 1 ? this.bends[bendIndex + 1] : end;

    // Snap X to prev or next (makes vertical segment)
    if (Math.abs(x - prev.x) < SNAP_THRESHOLD) x = prev.x;
    else if (Math.abs(x - next.x) < SNAP_THRESHOLD) x = next.x;

    // Snap Y to prev or next (makes horizontal segment)
    if (Math.abs(y - prev.y) < SNAP_THRESHOLD) y = prev.y;
    else if (Math.abs(y - next.y) < SNAP_THRESHOLD) y = next.y;

    return { x, y };
  }

  /**
   * If there are no user bends yet, copy the auto-route interior
   * points into this.bends so they become user-editable.
   */
  _promoteAutoBends() {
    if (this.bends.length === 0 && this._waypoints.length > 2) {
      this.bends = this._waypoints.slice(1, -1).map(p => ({ x: p.x, y: p.y }));
    }
    this._userEdited = true;
    this._savePorts();
  }

  /** Convert pointer event clientX/clientY → stage coordinates (zoom-aware). */
  _clientToStage(e) {
    const stage = this.group.closest('#stage-zoom') || this.group.closest('#stage');
    const rect  = stage.getBoundingClientRect();

    let zoom = 1;
    const transform = getComputedStyle(stage).transform;
    if (transform && transform !== 'none') {
      zoom = new DOMMatrix(transform).a;
    }

    return {
      x: (e.clientX - rect.left) / zoom,
      y: (e.clientY - rect.top)  / zoom
    };
  }
}


/* ================================================================== */
/*  Factory                                                            */
/* ================================================================== */

export function createOrthogonalEdge(svgRoot, boxes, fromId, toId, onSelect) {
  const group = document.createElementNS(SVG_NS, 'g');
  group.classList.add('edge');
  svgRoot.appendChild(group);

  const edge = new OrthogonalEdge(boxes.get(fromId), boxes.get(toId), group);
  edge.update();

  const handleClick = (e) => {
    e.stopPropagation();
    if (typeof onSelect === 'function') onSelect(edge);
  };

  edge.clickAreaEl.addEventListener('click', handleClick);
  edge.pathEl.addEventListener('click', handleClick);

  return edge;
}