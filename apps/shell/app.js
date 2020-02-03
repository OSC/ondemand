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
var schemes   = require('term-schemes')
var port = 3000;
var uuidv4 = require('uuid/v4');

//regular expression to find uuid in url
const regexPathMatch = /[a-f0-9]{8}-?[a-f0-9]{4}-?4[a-f0-9]{3}-?[89ab][a-f0-9]{3}-?[a-f0-9]{12}/i;
const regexFileMatch = /^.*\.(js|itermcolors|colorscheme|colors|terminal|config|config_0|theme|xrdb|xresources)$/gmi;
const xdg_config_dir = (process.env["XDG_CONFIG_DIR"] || path.join(os.homedir(), ".config"));



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

//check if directory exists to avoid any errors about the non-existence of the directory.
function checkDirExists(dir) {
    fs.stat(dir, function(err, stats) {
        if (err || err.errno == 34) {
            return false;
        }

        return true;
    });
}

//This removes any possible duplicates between the two arrays that I concat together.
function removeDuplicates(arr) {
    return [...new Set(array)];
}

//this returns the array of all the files within the one or two directories that contain the color schemes.
function getSchemeFiles() {
    var schemeFiles = [];

    var userDir = path.join(xdg_config_dir, "apps", "shell", "themes");
    var systemDir = path.join();

    if (checkDirExists(userDir)) {

        var userFiles = fs.readdirSync(userDir);
        var systemFiles = fs.readdirSync(systemDir);

        schemeFiles.concat(userFiles, systemDir);

        return removeDuplicates(schemeFiles);

    } else if (checkDirExists(systemDir)) {
        var systemFiles = fs.readdirSync(systemDir)

        return systemFiles;

    } 

    //returning an empty array will make the launch.hbs render a different looking view
    return [];



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

    return `#${rgbToHexMath(red)}+${rgbToHexMath(green)}+${rgbToHexMath(blue)}`;
}

const readFile = util.promisify(fs.readFile);

async function getColorSchemeFile(file) {
    const raw = String(await readFile(`${file}`))
}

// Create all your routes
var router = express.Router();
router.get('/', function (req, res) {
  res.redirect(req.baseUrl + `/ssh/`);
});


router.get('/ssh/*', function (req, res, next) {
    
    //create new id per session.
    var id = uuidv4();

    //redirect to newly created session with url.
    res.redirect(req.baseUrl + `/session/${id}/${req.params[0]}`);

});



router.get('/session/:id/*', function (req, res) {

  res.render('index', { baseURI: req.baseUrl });

});

router.get('/launch/', function (req, res) {

    res.render('launch', { baseURI: req.baseUrl, sessions: terminals.sessionsInfo(), fileOptions: getSchemeFiles() });

});

//This is the route that needs to know which directory it is from. Then it parses that. I was gonna use something similar to the getSchemeFiles function.
router.post('/color-scheme', function (req, res, next) {
    var schemeFile = req.param('color-scheme');
    var schemeDestination = req.param('session');

    var ext = schemeFile.split('.').pop();

    switch(ext) {
        case "itermcolors":
        //logic for parser
        break;

        case "colorscheme":
       //logic for parser
        break;

        case "js":
        //logic for parser
        break;

        case "colors":
         //logic for parser
        break;

        case "terminal":
         //logic for parser
        break;

        case "config":
        //logic for parser
        break;

        case "config_0":
        //logic for parser
        break;

        case "theme":
        //logic for parser
        break;

        case "xrdb" || "Xresources":
        //logic for parser
        break;

    }

    next();


})



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
  
 


});

server.listen(port, function () {
  console.log('Listening on ' + port);
});
