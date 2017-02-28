// Set dotenv as early as possible
require('dotenv').config();

// Monkey patch Regexp because Javascript is sad
RegExp.escape = function(s) {
  return s.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&');
};

var express  = require('express');
var exphbs   = require('express-handlebars');
var http     = require('http');
var path     = require('path');
var server   = require('socket.io');
var pty      = require('pty.js');
var fs       = require('fs');

var BASE_URI  = require('base-uri');
var SSH_URI   = "/ssh"
var PORT      = 1337;
var URI_REGEX = RegExp.escape(BASE_URI) +
                RegExp.escape(SSH_URI) +
                '\\/([\\w\\-.]+)' +
                '(.*)$';

var sshport = 22;

// Use express to handle the routes and rendering
var app = express();

// Use handlebars as the renderer
app.engine('handlebars', exphbs());
app.set('view engine', 'handlebars');

// Set up the routes
app.get(BASE_URI, function(req, res) {
  res.redirect(BASE_URI + SSH_URI + '/default');
});
app.get(BASE_URI + SSH_URI + '/*', function(req, res) {
  res.render('index', {
    baseURI: BASE_URI
  });
});
app.use(BASE_URI + '/wetty', express.static(path.join(__dirname, 'node_modules/wetty/public/wetty')));

// Start up the http server
var httpserv = http.createServer(app).listen(PORT, function() {
  console.log('http on port ' + PORT);
});

// Start up socket server
var io = server(httpserv, {
  path: BASE_URI + '/socket.io'
});

io.on('connection', function(socket) {
  var request = socket.request;
  console.log((new Date()) + ' Connection accepted.');

  // find user requested host from white list of hosts as well as user
  // requested cwd
  var sshhost = null;
  var cwd = null;
  if (match = request.headers.referer.match(URI_REGEX)) {
    sshhost = match[1]

    // check if dir exists and user has access to it
    var tmpdir = process.cwd();
    try {
      process.chdir(match[2]);
      cwd = match[2];
    } catch (err) {
      // ignore
    }
    process.chdir(tmpdir);
  }

  // Use default ssh host if "default" specified
  if (sshhost == null || sshhost == "default") { //process.env.DEFAULT_SSHHOST != null) {
    sshhost = process.env.DEFAULT_SSHHOST || 'localhost';
  }

  process.env.LANG = 'en_US.UTF-8'; // fixes strange character issues

  // set up arguments for launching ssh session
  var term_args = [sshhost, '-p', sshport];
  if (cwd !== null) {
    term_args.push('-t', 'cd ' + cwd + ' ; exec bash -l');
  }

  // launch an ssh session
  var term = pty.spawn('ssh', term_args, {
    name: 'xterm-256color',
    cols: 80,
    rows: 30
  });
  console.log((new Date()) + " PID=" + term.pid + " STARTED on behalf of user");

  term.on('data', function(data) {
    socket.emit('output', data);
  });
  term.on('exit', function(code) {
    console.log((new Date()) + " PID=" + term.pid + " ENDED");
  });

  socket.on('resize', function(data) {
    term.resize(data.col, data.row);
  });
  socket.on('input', function(data) {
    term.write(data);
  });
  socket.on('disconnect', function() {
    term.end();
  });
});
