const fs = require('fs');
const http = require('http');
const path = require('path');
const WebSocket = require('ws');
const express = require('express');
const pty = require('node-pty');
const dotenv = require('dotenv');
const Tokens = require('csrf');
const port = 3000;

// Read in environment variables
dotenv.config({ path: '.env.local' });
if (process.env.NODE_ENV === 'production') {
  dotenv.config({ path: '/etc/ood/config/apps/shell/env' });
}

const {
  parseUrl,
  hostAllowList,
  defaultServerOrigin,
  customServerOrigin,
  wsErrorMessage,
} = require('./utils/helpers');

// Keep app backwards compatible
if (fs.existsSync('.env')) {
  console.warn(
    "[DEPRECATION] The file '.env' is being deprecated. Please move this file to '/etc/ood/config/apps/shell/env'.",
  );
  dotenv.config({ path: '.env' });
}

const tokens = new Tokens({});
const secret = tokens.secretSync();

// Create all your routes
const router = express.Router();
router.get('/', (req, res) => {
  res.redirect(req.baseUrl + '/ssh');
});

router.get('/ssh*', (req, res) => {
  res.render('index', {
    baseURI: req.baseUrl,
    csrfToken: tokens.create(secret),
  });
});

router.use(express.static(path.join(__dirname, 'public')));

// Setup app
const app = express();

// Setup template engine
app.set('view engine', 'hbs');
app.set('views', path.join(__dirname, 'views'));

// Mount the routes at the base URI
app.use(process.env.PASSENGER_BASE_URI || '/', router);

// Setup websocket server
const server = new http.createServer(app);
const wss = new WebSocket.Server({ noServer: true });

wss.on('connection', (ws, req) => {
  const cmd = process.env.OOD_SSH_WRAPPER || 'ssh';

  console.log('Connection established');

  const [host, dir] = parseUrl(req.url);
  const args = dir
    ? [host, '-t', "cd '" + dir.replace(/'+/g, '\\') + "' ; exec ${SHELL} -l"]
    : [host];

  process.env.LANG = 'en_US.UTF-8'; // this patch (from b996d36) lost when removing wetty (2c8a022)

  const term = pty.spawn(cmd, args, {
    name: 'xterm-256color',
    cols: 80,
    rows: 30,
  });

  console.log('Opened terminal: ' + term.pid);

  term.on('data', (data) => {
    ws.send(data, (error) => {
      if (error) console.log('Send error: ' + error.message);
    });
  });

  term.on('error', () => {
    ws.close();
  });

  term.on('close', () => {
    ws.close();
  });

  ws.on('message', (msg) => {
    msg = JSON.parse(msg);
    if (msg.input) term.write(msg.input);
    if (msg.resize)
      term.resize(parseInt(msg.resize.cols), parseInt(msg.resize.rows));
  });

  ws.on('close', () => {
    term.end();
    console.log('Closed terminal: ' + term.pid);
  });
});

server.on('upgrade', (request, socket, head) => {
  console.log(socket);
  const {
    url,
    headers: { origin: clientOrigin },
  } = request;

  const requestToken = new URL(url, clientOrigin).searchParams.get('csrf');
  const serverOrigin = customServerOrigin(defaultServerOrigin(request.headers));
  const [host] = parseUrl(request.url);

  if (
    clientOrigin &&
    serverOrigin.startsWith('http') &&
    serverOrigin &&
    clientOrigin !== serverOrigin
  ) {
    socket.write(wsErrorMessage('bad origin'));

    socket.destroy();
  } else if (!tokens.verify(secret, requestToken)) {
    socket.write(wsErrorMessage('bad csrf token'));

    socket.destroy();
  } else if (!hostAllowList().has(host)) {
    // host not in whitelist
    socket.write(wsErrorMessage('host not whitelisted'));

    socket.destroy();
  } else {
    wss.handleUpgrade(request, socket, head, (ws) => {
      wss.emit('connection', ws, request);
    });
  }
});

server.listen(port, () => {
  console.log('Listening on ' + port);
});
