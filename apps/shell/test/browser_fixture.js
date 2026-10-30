'use strict';

// Serve the real Shell view with a fake transport for manual browser checks.
// This fixture never connects to a remote shell or starts the application server.
const fs = require('fs');
const http = require('http');
const path = require('path');
const handlebars = require('hbs').handlebars;

const root = path.resolve(__dirname, '..');
const publicRoot = path.join(root, 'public');
handlebars.registerHelper('assetHash', () => 'fixture');
const render = handlebars.compile(fs.readFileSync(path.join(root, 'views/index.hbs'), 'utf8'));

// Runs before the view's scripts, replacing only the connection and viewport.
function installFixture(legacy) {
  if (legacy) window.PointerEvent = undefined;
  localStorage.setItem('ood_shell_mobile_keys', 'true');
  const viewport = new EventTarget();
  // The viewport meta tag is parsed after this setup script on mobile.
  let viewportHeight = null;
  Object.defineProperty(viewport, 'height', {
    get: () => viewportHeight === null ? innerHeight : viewportHeight
  });
  viewport.scale = 1;
  Object.defineProperty(window, 'visualViewport', { configurable: true, value: viewport });
  window.shellFixture = {
    inputs: [],
    setHeight(height) {
      viewportHeight = height;
      viewport.dispatchEvent(new Event('resize'));
    }
  };
  class Socket {
    constructor() {
      this.readyState = 0;
      setTimeout(() => { this.readyState = Socket.OPEN; this.onopen(); }, 0);
    }
    send(data) {
      const message = JSON.parse(data);
      if (message.input !== undefined) shellFixture.inputs.push(message.input);
    }
  }
  Socket.OPEN = 1;
  window.WebSocket = Socket;
}

const server = http.createServer(async (req, res) => {
  const url = new URL(req.url, 'http://localhost');
  if (url.pathname === '/') {
    const html = render({ siteTitle: 'Keypad fixture', host: 'example', colorThemes: { json_array: '[]' } });
    const setup = '<script>(' + installFixture.toString() + ')(' + (url.searchParams.get('legacy') === '1') + ');</script>';
    res.setHeader('Content-Type', 'text/html; charset=utf-8');
    res.end(html.replace('<head>', '<head>' + setup));
    return;
  }
  const filename = path.resolve(publicRoot, '.' + url.pathname);
  if (!filename.startsWith(publicRoot + path.sep)) {
    res.writeHead(404).end();
    return;
  }
  try {
    const data = await fs.promises.readFile(filename);
    if (filename.endsWith('.js')) res.setHeader('Content-Type', 'application/javascript');
    if (filename.endsWith('.css')) res.setHeader('Content-Type', 'text/css');
    res.end(data);
  } catch (err) {
    res.writeHead(404).end();
  }
});

if (require.main === module) {
  server.listen(0, '127.0.0.1', () => {
    console.log('Open http://127.0.0.1:' + server.address().port + '/ (or /?legacy=1)');
    console.log('Use shellFixture.setHeight(240) and inspect shellFixture.inputs in the browser console.');
  });
}
module.exports = server;
