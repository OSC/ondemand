var fs        = require('fs');
var http      = require('http');
var path      = require('path');
var WebSocket = require('ws');
var express   = require('express');
var pty       = require('node-pty');
var hbs       = require('hbs');
var dotenv    = require('dotenv');
var Tokens    = require('csrf');
var url       = require('url');
var uuidv4    = require('uuid/v4');
var port      = 3000;

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

  create: function (host, dir, uuid) {
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
    });

    ws.on('close', function () {
      term.end();
      console.log('Closed terminal: ' + term.pid);
    });

  }
}

// Setup websocket server
var server = new http.createServer(app);
var wss = new WebSocket.Server({ noServer: true });

wss.on('connection', function connection (ws, req) {
  var match;
  var host = process.env.DEFAULT_SSHHOST || 'localhost';
  var cmd = process.env.OOD_SSH_WRAPPER || 'ssh';
  var dir;
  var uuid;
  var host_path_rx = `/session/([a-f0-9\-]+)/([^\\/\\?]+)([^\\?]+)?(\\?.*)?$`;

  console.log('Connection established');

  // Determine host and dir from request URL
  if (match = req.url.match(process.env.PASSENGER_BASE_URI + host_path_rx)) {
    uuid = match[1];
    if (match[2] !== 'default') host = match[2];
    if (match[3]) dir = decodeURIComponent(match[3]);
  }

  if (terminals.exists(uuid) === false) {
    terminals.create(host, dir, uuid);
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
  var requestToken = new URLSearchParams(url.parse(request.url).search).get('csrf'),
      client_origin = request.headers['origin'],
      server_origin = custom_server_origin(default_server_origin(request.headers));

  if (client_origin &&
      client_origin.startsWith('http') &&
      server_origin && client_origin !== server_origin
  ) {
    socket.write([
      'HTTP/1.1 401 Unauthorized',
      'Content-Type: text/html; charset=UTF-8',
      'Content-Encoding: UTF-8',
      'Connection: close',
      'X-OOD-Failure-Reason: invalid origin',
    ].join('\r\n') + '\r\n\r\n');

    socket.destroy();
  }
  else if (!tokens.verify(secret, requestToken)) {
    socket.write([
      'HTTP/1.1 401 Unauthorized',
      'Content-Type: text/html; charset=UTF-8',
      'Content-Encoding: UTF-8',
      'Connection: close',
      'X-OOD-Failure-Reason: bad csrf token',
    ].join('\r\n') + '\r\n\r\n');

    socket.destroy();

  }else{
    wss.handleUpgrade(request, socket, head, function done(ws) {
      wss.emit('connection', ws, request);
    });
  }
});

server.listen(port, function () {
  console.log('Listening on ' + port);
});
