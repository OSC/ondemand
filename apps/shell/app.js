const fs        = require('fs');
const http      = require('http');
const path      = require('path');
const WebSocket = require('ws');
const express   = require('express');
const pty       = require('node-pty');
const hbs       = require('hbs');
const dotenv    = require('dotenv');
const Tokens    = require('csrf');
const url       = require('url');
const yaml      = require('js-yaml');
const glob      = require('glob');
const port      = 3000;
const host_path_rx = '/ssh/([^\\/\\?]+)([^\\?]+)?(\\?.*)?$';
const helpers   = require('./utils/helpers');


// Read in environment variables
dotenv.config({path: '.env.local'});
if (process.env.NODE_ENV === 'production') {
  dotenv.config({path: '/etc/ood/config/apps/shell/env'});
}

// Keep app backwards compatible
if (fs.existsSync('.env')) {
  console.warn('[DEPRECATION] The file \'.env\' is being deprecated. Please move this file to \'/etc/ood/config/apps/shell/env\'.');
  dotenv.config({path: '.env'});
}

// Load color themes
var color_themes = {dark: [], light: []};
glob.sync('./color_themes/light/*').forEach(f => color_themes.light.push(require(path.resolve(f))));
glob.sync('./color_themes/dark/*').forEach(f => color_themes.dark.push(require(path.resolve(f))));
color_themes.json_array = JSON.stringify([...color_themes.light, ...color_themes.dark]);


const tokens = new Tokens({});
const secret = tokens.secretSync();

// Create all your routes
var router = express.Router();
router.get(['/', '/ssh'], function (req, res) {
  res.redirect(req.baseUrl + '/ssh/default');
});

router.get('/ssh*', function (req, res) {
  var theHost, theDir;
  [theHost, theDir] = host_and_dir_from_url(req.url);
  res.render('index',
    {
      baseURI: req.baseUrl,
      csrfToken: tokens.create(secret),
      host: theHost,
      dir: theDir,
      colorThemes: color_themes,
      siteTitle: (process.env.OOD_DASHBOARD_TITLE || "Open OnDemand"),
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

let host_allowlist = [];
if (process.env.OOD_SSHHOST_ALLOWLIST){
  host_allowlist = Array.from(new Set(process.env.OOD_SSHHOST_ALLOWLIST.split(':')));
}

const inactiveTimeout = (process.env.OOD_SHELL_INACTIVE_TIMEOUT_MS || 300000);
const maxShellTime = (process.env.OOD_SHELL_MAX_DURATION_MS || 3600000);
const pingPongEnabled = process.env.OOD_SHELL_PING_PONG ? true : false;

let hosts = helpers.definedHosts();
let default_sshhost = hosts['default'];
hosts['hosts'].forEach((host) => {
  host_allowlist.push(host);
});

function host_and_dir_from_url(url){
  let match = url.match(host_path_rx), 
  hostname = null, 
  directory = null;

  if (match) {
    hostname = match[1] === "default" ? default_sshhost : match[1];
    directory = match[2] ? decodeURIComponent(match[2]) : null;
  }
  return [hostname, directory];
}

function custom_server_origin(default_value = null){
  var custom_origin = null;

  if(process.env.OOD_SHELL_ORIGIN_CHECK) {
    // if ENV is set, do not use default!
    if(process.env.OOD_SHELL_ORIGIN_CHECK.startsWith('http')){
      custom_origin = process.env.OOD_SHELL_ORIGIN_CHECK;
    }
  }
  else {
    custom_origin = default_value;
  }

  return custom_origin;
}

function default_server_origin(headers){
  var origin = null;

  if (headers['x-forwarded-proto'] && headers['x-forwarded-host']){
    origin = headers['x-forwarded-proto'] + "://" + headers['x-forwarded-host']
  }

  return origin;
}

function detect_auth_error(requestToken, client_origin, server_origin, host) {
  if (host_allowlist.length == 0) {
    return "No clusters defined.";
  } else if (client_origin &&
    client_origin.startsWith('http') &&
    server_origin && client_origin !== server_origin) {
    return "Invalid Origin.";
  } else if (!tokens.verify(secret, requestToken)) {
    return "Bad CSRF Token.";
  } else if (!helpers.hostInAllowList(host_allowlist, host)) {
    return `Host "${host}" not specified in allowlist or cluster configs.`;
  } else {
    return null;
  }
}

wss.on('connection', function connection (ws, req) {
  var dir,
      term,
      args,
      host,
      cmd = process.env.OOD_SSH_WRAPPER || 'ssh';
  
  ws.isAlive = true;
  ws.startedAt = Date.now();
  ws.lastActivity = Date.now();
  ws.lastLog = Date.now();
  
  console.log('Connection established');

  [host, dir] = host_and_dir_from_url(req.url);

  // Verify authentication
  token = req.url.match(/csrf=([^&]*)/)[1];
  authError = detect_auth_error(token, req.origin, custom_server_origin(default_server_origin(req)), host);
  if (authError) {
    // 3146 has no meaning, any number between 3000-3999 is fair to use
    ws.close(3146, authError);
  } else {
    args = dir ? [host, '-t', 'cd \'' + dir.replace(/\'/g, "'\\''") + '\' ; exec ${SHELL} -l'] : [host];

    process.env.LANG = 'en_US.UTF-8'; // this patch (from b996d36) lost when removing wetty (2c8a022)

    term = pty.spawn(cmd, args, {
      name: 'xterm-16color',
      cols: 80,
      rows: 30
    });
    

    console.log('Opened terminal: ' + term.pid);

    term.onData(function (data) {
      ws.send(data, function (error) {
        if(ws.readyState === WebSocket.CLOSED || ws.readyState === WebSocket.CLOSING) {
          // nothing to do. websocket is closed or closing, so the error is likely about that.
        } else if (error) {
          const logDelta = Date.now() - ws.lastLog;

          // rate limit logging errors here to once a minute.
          if(logDelta >= 60000) {
            console.log('Send error: ' + error.message);
            ws.lastLog = Date.now();
          }
        }
      });
      ws.lastActivity = Date.now();
    });

    term.onExit(function (_exitData) {
      ws.close();
    });

    ws.on('message', function (msg) {
      msg = JSON.parse(msg);
      if (msg.input)  {
        term.write(msg.input);
        this.lastActivity = Date.now();
      }
      if (msg.resize) term.resize(parseInt(msg.resize.cols), parseInt(msg.resize.rows));
    });

    ws.on('close', function () {
      term.end();
      this.isAlive = false;
      console.log('Closed terminal: ' + term.pid);
    });

    ws.on('pong', function () {
      this.isAlive = true;
    });
  }
});

const interval = setInterval(function ping() {
  wss.clients.forEach(function each(ws) {
    const timeUsed = Date.now() - ws.startedAt;
    const inactiveFor = Date.now() - ws.lastActivity;
    if (ws.isAlive === false || inactiveFor > inactiveTimeout || timeUsed > maxShellTime) {
      return ws.terminate();
    }

    if(pingPongEnabled) {
      ws.isAlive = false;
      ws.ping();
    }
  });
}, 30000);

wss.on('close', function close() {
  clearInterval(interval);
});

server.on('upgrade', function upgrade(request, socket, head) {
  wss.handleUpgrade(request, socket, head, function done(ws) {
    wss.emit('connection', ws, request);
  });
});

server.listen(port, function () {
  console.log('Listening on ' + port);
});
