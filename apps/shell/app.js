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
const os        = require('os');
const termSchemes   = require('term-schemes');
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

//Start Terminal Color Scheme Implementation
//declared constants for directory paths
const xdg_config_dir = (process.env["XDG_CONFIG_HOME"] || path.join(os.homedir(), ".config"));
const ood_app_config_root = (process.env["OOD_APP_CONFIG_ROOT"] || '/etc/ood/config/ondemand/apps/shell');
const userDir = path.join(xdg_config_dir, "ondemand", "apps", "shell", "themes");
const systemDir = path.join(ood_app_config_root, "themes");

//Search directories and make directory if not present.
fs.mkdirSync(userDir, {recursive: true});
 var schemeObjects = {...getSchemeObjects(userDir), ...getSchemeObjects(systemDir)};

//Parses through the files and returns them as objects.
function getSchemeObjects(dir) {
  var schemes = {};

  try {
    fs.readdirSync(dir).forEach(function(file) {
      fileInfo = path.parse(file);
      schemes[fileInfo.name] = {name: fileInfo.name, file: fileInfo.base, ext: fileInfo.ext, dir: dir}
    });
    return schemes;
  } catch (err) {
    return {};
  }
}

// Show list of options for color schemes.
function getSchemeFilesArray() {

    return Object.keys(schemeObjects).map(i => schemeObjects[i])
}

//Converts the colors returned by term-scheme to a hex number. This allows the colors to play nicely with hterm.
function rgbToHexMath (num) { 
  var hex = Number(num).toString(16);
  if (hex.length < 2) {
       hex = "0" + hex;
  }
  return hex;
};

//Converts to a complete hex color.
function hexConverter (array) {
    var red = array[0];
    var green = array[1];
    var blue = array[2];

    return `#${rgbToHexMath(red)}${rgbToHexMath(green)}${rgbToHexMath(blue)}`.toUpperCase();
}

//Finds the host of the terminal and returns that value.
function findHost(uuid) {
    sessions = terminals.instances;
    var host = sessions[uuid].host;

    return host;
}

//Parses through the various file types of the terminal schemes.
function parseFile(fileObject) {
    
    const ext = fileObject.ext;
    const file = fileObject.dir + "/" + fileObject.file;
    const raw = String(fs.readFileSync(file));

    const schemes = {
      ".itermcolors": termSchemes.iterm2,
      ".colorscheme": termSchemes.konsole,
      ".colors": termSchemes.remmina,
      ".terminal":termSchemes.terminal,
      ".config": termSchemes.terminator,
      ".config_0": termSchemes.tilda,
      ".theme": termSchemes.xfce,
      ".txt": termSchemes.termite,
      ".Xresources": termSchemes.xresources,
      ".xrdb": termSchemes.xresources,
    }
    try {
      return schemes[ext](raw)
    } catch (err) {
      return {error: "unknown file type."}
    }
}

//Converts scheme colors to an object.
function convertSchemeObject(obj) {
    newSchemeObj = {};
    colorArray = [];
    for (var key of Object.keys(obj)) {
       if(isNaN(key) === false) {
           
           colorArray.push(hexConverter(obj[key]));
       
        } else if (isNaN(key)) {
            newSchemeObj[key] = hexConverter(obj[key]);
        }

    }

    newSchemeObj["colorPaletteOverrides"] = colorArray;

    return newSchemeObj;
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


//For laumch page to start a new session with color scheme and host.
router.get('/new-session', function(req, res, next) {
    var id = uuidv4();


    res.redirect(url.format({
        pathname: req.baseUrl + "/custom-term",
        query: {
            "host": req.query.host + ".osc.edu",
            "scheme": req.query.scheme,
            "session": id
        }
    }));

});

router.get('/custom-term', function(req, res, next) {
    res.locals.uuid = req.query.session;
    var fileObject, schemeObject, schemeColorConvert;
    var defaultObj = {
        'use-default-window-copy': true,
        'ctrl-v-paste': true,
        'ctrl-c-copy': true,
        'cursor-blink': true,
        };

    res.locals.schemeObject;
    if (req.query.scheme === "default") {
       if ('default' in schemeObjects) {
        fileObject = schemeObjects[req.query.scheme];
        schemeObject = parseFile(fileObject);
        schemeColorConvert = convertSchemeObject(schemeObject);
        res.locals.schemeObject = schemeColorConvert;
       } else {

        res.locals.schemeObject = defaultObj;
       }
    } else {
     
     fileObject = schemeObjects[req.query.scheme];
     schemeObject = parseFile(fileObject);
     schemeColorConvert = convertSchemeObject(schemeObject);
     res.locals.schemeObject = schemeColorConvert;        
    }

    next();

}, function(req, res, next) {
    res.locals.host = req.query.host || findHost(req.query.session);
    console.log(res.locals.schemeObject);
    var cookieValue = JSON.stringify(res.locals.schemeObject);

    res.cookie(res.locals.uuid, cookieValue, {expires: new Date(Date.now() + 8 * 3600000) });

    next();   

}, function(req, res, next) {

    res.redirect(req.baseUrl + `/session/${req.query.session}/${res.locals.host}`)
})


router.get('/session/:id*', function (req, res) {

  res.render('index',
    {
      baseURI: req.baseUrl,
      csrfToken: tokens.create(secret),
      session: req.params.id
    });

});

router.get('/launch', function (req, res) {

  res.render('launch', {baseURI: req.baseUrl, sessions: terminals.sessionsInfo(), fileOptions: getSchemeFilesArray() || []});
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
      console.log("error present");
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

    ws.on('close', function (code, reason) {
      console.log(code);
      if (code === 3000) {
        term.end();
        console.log('Closed terminal: ' + term.pid);
      } else if (code === 1001){
        term.pause();
        console.log('Paused terminal: ' + term.pid);
      } else {
        term.end();
        console.log('Closed terminal: ' + term.pid);
      }
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
  id = match[1],
  hostname = match[2] === "default" ? default_sshhost : match[2],
  directory = match[3] ? decodeURIComponent(match[3]) : null;

  return [id, hostname, directory];
}

wss.on('connection', function connection (ws, req) {

  var dir,
     term,
     args,
     host,
     uuid,
     cmd = process.env.OOD_SSH_WRAPPER || 'ssh';

  console.log('Connection established');
  

  [uuid, host, dir] = host_and_dir_from_url(req.url);
  args = dir ? [host, '-t', 'cd \'' + dir.replace(/\'/g, "'\\''") + '\' ; exec ${SHELL} -l'] : [host];

  if (terminals.exists(uuid) === false) {
    terminals.create(host, dir, uuid, cmd);
  }
  
  try {
  terminals.attach(uuid, ws);
} catch(e) {
  terminals.create(host, dir, uuid, cmd);
  terminals.attach(uuid, ws);
}
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
  var uuid, host, dir;
  [uuid, host, dir] = host_and_dir_from_url(request.url);

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
