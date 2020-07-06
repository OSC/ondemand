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
const glob      = require("glob");
const uuidv4    = require('uuid/v4');
const port      = 3000;
const host_path_rx = `/session/([a-f0-9\-]+)/([^\\/\\?]+)([^\\?]+)?(\\?.*)?$`;

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

const tokens = new Tokens({});
const secret = tokens.secretSync();

// Create all your routes
var router = express.Router();
router.get('/', function (req, res) {
  res.redirect(req.baseUrl + '/ssh');
});

router.get('/ssh*', function (req, res) {

  var id = uuidv4();

  res.redirect(req.baseUrl + `/session/${id + req.params[0]}`);

});

router.get('/session/:id*', function (req, res) {

  res.render('index',
    {
      baseURI: req.baseUrl,
      csrfToken: tokens.create(secret),
    });

});

router.get('/launch', function (req, res) {

  res.render('launch', {baseURI: req.baseUrl, sessions: terminals.sessionsInfo()});

})

router.use(express.static(path.join(__dirname, 'public')));

// Setup app
var app = express();

// Setup template engine
app.set('view engine', 'hbs');
app.set('views', path.join(__dirname, 'views'));

// Mount the routes at the base URI
app.use(process.env.PASSENGER_BASE_URI || '/', router);

var terminals = {

  instances: {

  },

  sessionsInfo: function () {

    return Object.entries(this.instances)
          .sort()
          .map(function(array){ return {id: array[0], host: array[1].host }; });
  },

  create: function (host, dir, uuid, cmd) {
    var cmd = 'ssh';
    var args = dir ? [host, '-t', 'cd \'' + dir.replace(/\'/g, "'\\''") + '\' ; exec ${SHELL} -l'] : [host];

    process.env.LANG = 'en_US.UTF-8'; // this patch (from b996d36) lost when removing wetty (2c8a022)

    this.instances[uuid] = {term: pty.spawn(cmd, args, {
      name: 'xterm-256color',
      cols: 80,
      rows: 30
    }), host: host}

    return uuid;
  },

  exists: function (uuid) {
    if (uuid in this.instances) {
      return true;
    } else {
      return false;
    }
  },

  get: function (uuid) {
    return this.instances[uuid].term;
  },

  attach: function (uuid, ws) {
    var term = this.get(uuid);
    term.resume();
    term.resize(80, 30);

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
      if (msg.input)  term.write(msg.input);
      if (msg.resize) term.resize(parseInt(msg.resize.cols), parseInt(msg.resize.rows));
      if (msg.close) {
        term.end();
        ws.close();
      }
    });

    ws.on('close', function () {
      term.pause();
      console.log('Closed terminal: ' + term.pid);
    });

  }
}

// Setup websocket server
const server = new http.createServer(app);
const wss = new WebSocket.Server({ noServer: true });

let host_whitelist = new Set;
if (process.env.SSHHOST_WHITELIST){
  host_whitelist = new Set(process.env.SSHHOST_WHITELIST.split(':'));
}

let default_sshhost;
glob.sync(path.join((process.env.OOD_CLUSTERS || '/etc/ood/config/clusters.d'), '*.y*ml'))
  .map(yml => yaml.safeLoad(fs.readFileSync(yml)))
  .filter(config => (config.v2 && config.v2.login && config.v2.login.host) && ! (config.v2 && config.v2.metadata && config.v2.metadata.hidden))
  .forEach((config) => {
    let host = config.v2.login.host; //Already did checking above
    let isDefault = config.v2.login.default;
    host_whitelist.add(host);
    if (isDefault) default_sshhost = host;
  });

default_sshhost = process.env.DEFAULT_SSHHOST || default_sshhost;
function host_and_dir_from_url(url){
  let match = url.match(host_path_rx),
  hostname = match[1] === "default" ? default_sshhost : match[1],
  directory = match[2] ? decodeURIComponent(match[2]) : null;

  return [hostname, directory];
}

wss.on('connection', function connection (ws, req) {

  var dir,
     term,
     args,
     host,
     uuid,
     cmd = process.env.OOD_SSH_WRAPPER || 'ssh';

  console.log('Connection established');

  [host, dir] = host_and_dir_from_url(req.url);
  args = dir ? [host, '-t', 'cd \'' + dir.replace(/\'/g, "'\\''") + '\' ; exec ${SHELL} -l'] : [host];

  if (terminals.exists(uuid) === false) {
    terminals.create(host, dir, uuid, cmd);
  }
  
  terminals.attach(uuid, ws);
});

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

server.on('upgrade', function upgrade(request, socket, head) {
  const requestToken = new URLSearchParams(url.parse(request.url).search).get('csrf'),
        client_origin = request.headers['origin'],
        server_origin = custom_server_origin(default_server_origin(request.headers));
  var host, dir;
  [host, dir] = host_and_dir_from_url(request.url);

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
  } else if (!host_whitelist.has(host)){ // host not in whitelist
    socket.write([
      'HTTP/1.1 401 Unauthorized',
      'Content-Type: text/html; charset=UTF-8',
      'Content-Encoding: UTF-8',
      'Connection: close',
      'X-OOD-Failure-Reason: host not whitelisted',
    ].join('\r\n') + '\r\n\r\n');

    socket.destroy();
  } else{
    wss.handleUpgrade(request, socket, head, function done(ws) {
      wss.emit('connection', ws, request);
    });
  }
});

server.listen(port, function () {
  console.log('Listening on ' + port);
});
