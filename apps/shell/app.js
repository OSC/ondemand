var fs        = require('fs');
var http      = require('http');
var path      = require('path');
var WebSocket = require('ws');
var express   = require('express');
var pty       = require('node-pty');
var hbs       = require('hbs');
var dotenv    = require('dotenv');
var port = 3000;
var uuidv4 = require('uuid/v4');
const regexPathMatch = /[a-f0-9]{8}-?[a-f0-9]{4}-?4[a-f0-9]{3}-?[89ab][a-f0-9]{3}-?[a-f0-9]{12}/i;


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

// Create all your routes
var router = express.Router();
router.get('/', function (req, res) {
  res.redirect(req.baseUrl + `/ssh`);
});
/*
router.get('/ssh*', function (req, res, next) {
    if (regexPathMatch.test(req.path) === false) {
        currentId = uuidv4();
        res.redirect(req.baseUrl + `/ssh/${currentId}`);
        next('route')
    } else {
        var extraction = regexPathMatch.exec(req.path);
        currentId = extraction[0];
        next('route')
    }

});
*/


router.get('/ssh*', function (req, res, next) {
    var id = uuidv4();

    res.redirect(req.baseUrl + `/ssh-session/${id}`);

});



router.get('/ssh-session/:id*', function (req, res) {
  res.render('index', { baseURI: req.baseUrl });

});


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

    create: function (host, dir, uuid) {
        var cmd = 'ssh';
        var args = dir ? [host, '-t', 'cd \'' + dir.replace(/\'/g, "'\\''") + '\' ; exec ${SHELL} -l'] : [host];

        this.instances[uuid] = pty.spawn(cmd, args, {
            name: 'xterm-256color',
            cols: 80,
            rows: 30
        });
        return uuid;
    },

    exists: function (uuid) {
        if (uuid in instances) {
            return true;
        } else {
            return false;
        }
    },

    get: function (uuid) {
        return this.instances[uuid];
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
            console.log(error);
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
            term.pause();
            console.log('Kept terminal: ' + term.pid);
        });

        ws.on('reconnect', () => {
            console.log('terminal program resumed.' + term.pid);
        });

    }
}


// Setup websocket server
var server = new http.createServer(app);
var wss = new WebSocket.Server({ server: server });

wss.on('connection', function connection (ws, req) {
  var match;
  var host = process.env.DEFAULT_SSHHOST || 'localhost';
  var dir;
  var extraction = regexPathMatch.exec(ws.upgradeReq.url);
  var uuid = extraction[0];
  
  console.log('Connection established');



  // Determine host and dir from request URL
  if (match = ws.upgradeReq.url.match(process.env.PASSENGER_BASE_URI + '/ssh/([^\\/]+)(.+)?$')) {
    if (match[1] !== 'default') host = match[1];
    if (match[2]) dir = decodeURIComponent(match[2]);
  }

    if (terminals.exists(uuid) === false) {
        terminals.create(host, dir, uuid);
    }

    terminals.attach(uuid, ws);

  process.env.LANG = 'en_US.UTF-8'; // this patch (from b996d36) lost when removing wetty (2c8a022)
  
 


});

server.listen(port, function () {
  console.log('Listening on ' + port);
});
