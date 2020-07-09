const fs = require('fs');
const http = require('http');
const path = require('path');
const WebSocket = require('ws');
const express = require('express');
const pty = require('node-pty');
const hbs = require('hbs');
const dotenv = require('dotenv');
const Tokens = require('csrf');
const url = require('url');
const yaml = require('js-yaml');
const glob = require("glob");
const port = 3000;

// Read in environment variables
dotenv.config({ path: '.env.local' });
if (process.env.NODE_ENV === 'production') {
  dotenv.config({ path: '/etc/ood/config/apps/shell/env' });
}

const helpers = require('./utils/helpers.js')

// Keep app backwards compatible
if (fs.existsSync('.env')) {
  console.warn('[DEPRECATION] The file \'.env\' is being deprecated. Please move this file to \'/etc/ood/config/apps/shell/env\'.');
  dotenv.config({ path: '.env' });
}

const tokens = new Tokens({});
const secret = tokens.secretSync();

// Create all your routes
var router = express.Router();
router.get('/', function (req, res) {
  res.redirect(req.baseUrl + '/ssh');
});

router.get('/ssh*', function (req, res) {
  res.render('index',
    {
      baseURI: req.baseUrl,
      csrfToken: tokens.create(secret),
    });
});

router.use(express.static(path.join(__dirname, 'public')));

// Setup app
var app = express();

// Setup template engine
app.set('view engine', 'hbs');
app.set('views', path.join(__dirname, 'views'));

// Mount the routes at the base URI
app.use(process.env.PASSENGER_BASE_URI || '/', router);

// Setup websocket server
const server = new http.createServer(app);
const wss = new WebSocket.Server({ noServer: true });

wss.on('connection', function connection(ws, req) {
  var dir,
    term,
    args,
    host,
    cmd = process.env.OOD_SSH_WRAPPER || 'ssh';

  console.log('Connection established');

  [host, dir] = helpers.host_and_dir_from_url(req.url);
  args = dir ? [host, '-t', 'cd \'' + dir.replace(/\'/g, "'\\''") + '\' ; exec ${SHELL} -l'] : [host];

  process.env.LANG = 'en_US.UTF-8'; // this patch (from b996d36) lost when removing wetty (2c8a022)

  term = pty.spawn(cmd, args, {
    name: 'xterm-256color',
    cols: 80,
    rows: 30
  });

  console.log('Opened terminal: ' + term.pid);

  term.on('data', function (data) {
    ws.send(data, function (error) {
      if (error) console.log('Send error: ' + error.message);
    });
  });

  term.on('error', function (error) {
    ws.close();
  });

  term.on('close', function () {
    ws.close();
  });

  ws.on('message', function (msg) {
    msg = JSON.parse(msg);
    if (msg.input) term.write(msg.input);
    if (msg.resize) term.resize(parseInt(msg.resize.cols), parseInt(msg.resize.rows));
  });

  ws.on('close', function () {
    term.end();
    console.log('Closed terminal: ' + term.pid);
  });
});

function custom_server_origin(default_value = null) {
  var custom_origin = null;

  if (process.env.OOD_SHELL_ORIGIN_CHECK) {
    // if ENV is set, do not use default!
    if (process.env.OOD_SHELL_ORIGIN_CHECK.startsWith('http')) {
      custom_origin = process.env.OOD_SHELL_ORIGIN_CHECK;
    }
  }
  else {
    custom_origin = default_value;
  }

  return custom_origin;
}

function default_server_origin(headers) {
  var origin = null;

  if (headers['x-forwarded-proto'] && headers['x-forwarded-host']) {
    origin = headers['x-forwarded-proto'] + "://" + headers['x-forwarded-host']
  }

  return origin;
}

server.on('upgrade', function upgrade(request, socket, head) {
  const requestToken = new URLSearchParams(url.parse(request.url).search).get('csrf'),
    client_origin = request.headers['origin'],
    server_origin = custom_server_origin(default_server_origin(request.headers));
  var host, dir;
  [host, dir] = helpers.host_and_dir_from_url(request.url);

  if (client_origin &&
    client_origin.startsWith('http') &&
    server_origin && client_origin !== server_origin) {
    socket.write([
      'HTTP/1.1 401 Unauthorized',
      'Content-Type: text/html; charset=UTF-8',
      'Content-Encoding: UTF-8',
      'Connection: close',
      'X-OOD-Failure-Reason: invalid origin',
    ].join('\r\n') + '\r\n\r\n');

    socket.destroy();
  } else if (!tokens.verify(secret, requestToken)) {
    socket.write([
      'HTTP/1.1 401 Unauthorized',
      'Content-Type: text/html; charset=UTF-8',
      'Content-Encoding: UTF-8',
      'Connection: close',
      'X-OOD-Failure-Reason: bad csrf token',
    ].join('\r\n') + '\r\n\r\n');

    socket.destroy();
  } else if (!host_whitelist.has(host)) { // host not in whitelist
    socket.write([
      'HTTP/1.1 401 Unauthorized',
      'Content-Type: text/html; charset=UTF-8',
      'Content-Encoding: UTF-8',
      'Connection: close',
      'X-OOD-Failure-Reason: host not whitelisted',
    ].join('\r\n') + '\r\n\r\n');

    socket.destroy();
  } else {
    wss.handleUpgrade(request, socket, head, function done(ws) {
      wss.emit('connection', ws, request);
    });
  }
});

server.listen(port, function () {
  console.log('Listening on ' + port);
});
