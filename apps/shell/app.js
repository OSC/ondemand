var fs        = require('fs');
var http      = require('http');
var path      = require('path');
var WebSocket = require('ws');
var express   = require('express');
var pty       = require('node-pty');
var hbs       = require('hbs');
var util      = require('util')
var dotenv    = require('dotenv');
var os        = require('os');
var path      = require('path');
var url       = require('url');
var termSchemes   = require('term-schemes');
var port = 3000;
var uuidv4 = require('uuid/v4');

//regular expression to find uuid in url
const regexPathMatch = /[a-f0-9]{8}-?[a-f0-9]{4}-?4[a-f0-9]{3}-?[89ab][a-f0-9]{3}-?[a-f0-9]{12}/i;
const regexFileMatch = /^.*\.(js|itermcolors|colorscheme|colors|terminal|config|config_0|theme|xrdb|xresources|txt)$/gmi;
const xdg_config_dir = (process.env["XDG_CONFIG_DIR"] || path.join(os.homedir(), ".config"));
const ood_app_config_root = (process.env["OOD_APP_CONFIG_ROOT"] || '/etc/ood/config/apps/shell');
const userDir = path.join(xdg_config_dir, "apps", "shell", "themes");
const systemDir = path.join(ood_app_config_root, "themes");

var schemeObjects;

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

if (checkDirExists(userDir) && checkDirExists(systemDir)) {
    var user = getSchemeObjects(userDir);
    var system = getSchemeObjects(systemDir);

   schemeObjects = {...system, ...user};

} else if (checkDirExists(userDir)) {
    schemeObjects = getSchemeObjects(userDir);

} else if (checkDirExists(systemDir)) {
    schemeObjects = getSchemeObjects(systemDir);
}

//check if directory exists to avoid any errors about the non-existence of the directory.
function checkDirExists(dir) {
    try {
        if (fs.existsSync(dir)) {
            console.log('dir true')
            return true;
        } else {
            console.log('dir false')
            return false;
        }
    } catch(e) {
        console.log('error');
    }
 }

function getSchemeFileObject(base) {
    var userDir = path.join(xdg_config_dir, "apps", "shell", "themes");
    fs.readdirSync(userDir).forEach(file => {
        if (file === base) {
            return path.parse(file);
        }

    })
}


//this returns the array of all the files within the one or two directories that contain the color schemes.
function getSchemeFilesArray() {

    return Object.keys(schemeObjects).map(i => schemeObjects[i])
}




function getSchemeObjects(dir) {
    var schemes = {};
        
        fs.readdirSync(dir).forEach(function(file) {
        fileInfo = path.parse(file);
        schemes[fileInfo.name] = {name: fileInfo.name, file: fileInfo.base, ext: fileInfo.ext, dir: userDir};
    });
        return schemes;
}


//term-schemes return an rgb color but hterm.js reads hex. The next two functions return the color values in hex.
function rgbToHexMath (num) { 
  var hex = Number(num).toString(16);
  if (hex.length < 2) {
       hex = "0" + hex;
  }
  return hex;
};

function hexConverter (array) {
    var red = array[0];
    var green = array[1];
    var blue = array[2];

    return `#${rgbToHexMath(red)}${rgbToHexMath(green)}${rgbToHexMath(blue)}`.toUpperCase();
}

function findHost(uuid) {
    sessions = terminals.instances;
    var host = sessions[uuid].host;

    return host;

}

function parseFile(fileObject) {
    
    const ext = fileObject.ext;
    const file = fileObject.dir + "/" + fileObject.file;
    const raw = String(fs.readFileSync(file));
      
    switch(ext) {
        case ".itermcolors":
            return termSchemes.iterm2(raw);
        break;

        case ".colorscheme":
            return termSchemes.konsole(raw);
        break;

        case ".js":
            return termSchemes.hyper(raw);  
        break;

        case ".colors":
            return termSchemes.remmina(raw);
        break;

        case ".terminal":
            return termSchemes.terminal(raw);      
        break;

        case ".config":
            return termSchemes.terminator(raw);
        break;

        case ".config_0":
            return termSchemes.tilda(raw);
        break;

        case ".theme":
            return termSchemes.xfce(raw);
        break;

        case ".txt":
            return termSchemes.termite(raw);
        break;

        case ".xrdb" || ".Xresources":
            return termSchemes.xresources(raw);
        break;

        default:
            schemeError = {error: "unknown file type."}
            return schemeError;
        break; 

    }
}


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


// Create all your routes
var router = express.Router();
router.get('/', function (req, res) {
  res.redirect(req.baseUrl + `/launch/`);
});


router.get('/ssh/*', function (req, res, next) {
    
    //create new id per session.
    var id = uuidv4();

    //redirect to newly created session with url.
    res.redirect(req.baseUrl + `/session/${id}/${req.params[0]}`);

});

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

router.get('/session/:id/*', function (req, res) {

  res.render('index', { baseURI: req.baseUrl, session: req.params.id });

});

router.get('/launch/', function (req, res) {

    res.render('launch', { baseURI: req.baseUrl, sessions: terminals.sessionsInfo(), fileOptions: getSchemeFilesArray() });

});



router.use(express.static(path.join(__dirname, 'public')));

// Setup app
var app = express();

// Setup template engine
app.set('view engine', 'hbs');
app.set('views', path.join(__dirname, 'views'));

// Mount the routes at the base URI
app.use(process.env.PASSENGER_BASE_URI || '/', router);

//terminals object for sessions.
var terminals = {
    
    //session id storage object.
    instances: {

    },

    sessionsInfo: function () {

   return Object.entries(this.instances)
        .sort()
        .map(function(array){ return {id: array[0], host: array[1].host }; });

    },

    //create new terminals
    create: function (host, dir, uuid) {
        var cmd = 'ssh';
        var args = dir ? [host, '-t', 'cd \'' + dir.replace(/\'/g, "'\\''") + '\' ; exec ${SHELL} -l'] : [host];

        this.instances[uuid] = {term: pty.spawn(cmd, args, {
            name: 'xterm-256color',
            cols: 80,
            rows: 30
        }), host: host}

        return uuid;
    },

    //check if uuid exists.
    exists: function (uuid) {
        if (uuid in this.instances) {
            return true;
        } else {
            return false;
        }
    },

    //get the terminal from the uuid
    get: function (uuid) {
        return this.instances[uuid].term;
    },

    //attach the terminal to the websocket.
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
  var extraction = regexPathMatch.exec(req.url);
  var uuid = extraction[0];
  
  console.log('Connection established');




  // Determine host and dir from request URL
  if (match = req.url.match(process.env.PASSENGER_BASE_URI + `/session/${uuid}/([^\\/]+)(.+)?$`)) {
    if (match[1] !== 'default') host = match[1];
    if (match[2]) dir = decodeURIComponent(match[2]);
  }

    if (terminals.exists(uuid) === false) {
        terminals.create(host, dir, uuid);
    }

    terminals.attach(uuid, ws);

  process.env.LANG = 'en_US.UTF-8'; // this patch (from b996d36) lost when removing wetty (2c8a022)
  
console.log(getSchemeFilesArray());


});

server.listen(port, function () {
  console.log('Listening on ' + port);
});
