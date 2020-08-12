var http        = require('http'),
    fs          = require('fs'),
    path        = require('path'),
    url         = require('url'),
    cloudcmd    = require('cloudcmd'),
    CloudFunc   = require('cloudcmd/lib/cloudfunc'),
    express     = require('express'),
    io          = require('socket.io'),
    HOME        = require('os-homedir')(),
    BASE_URI    = require('base-uri'),
    archiver    = require('archiver'),
    queryString = require('querystring'),
    gitSync     = require('git-rev-sync'),
    dotenv      = require('dotenv'),
    expandTilde = require('expand-tilde'),
    app         = express(),
    dirArray    = __dirname.split('/'),
    PORT        = 9001,
    PREFIX      = '',
    server,
    socket;

// Read in environment variables
dotenv.config({path: '.env.local'});
if (process.env.NODE_ENV === 'production') {
    dotenv.config({path: '/etc/ood/config/apps/files/env'});
}

var startsWithAny = function(subject, prefixes){
    return prefixes.some(function(x){
        return subject.startsWith(x);
    });
};

function realpathSyncSafe(filepath){
    try {
	// resolve symlinks
        return fs.realpathSync(filepath);
    }
    catch(error){
	// exception thrown when path ! exist
        return filepath;
    }
}

function resolvePath(filepath) {
    return realpathSyncSafe(  // Resolve symlinks
        expandTilde(  // Resolve home directories
            path.normalize(filepath)  // Resolve . and ..
        )
    );
}

function sshAppUrls(hosts, shell_url) {
  return hosts.map(function(host) {
    return {
      ssh_host: shell_url.replace(/\/$/, '') + '/' + host.ssh_host,
      host_name: host.host_name
    };
  });
}

/**
 * The URL for the OnDemand Shell
 * @return {[type]} [description]
 */
function oodShellUrl() {
  return process.env.OOD_SHELL_URL ? process.env.OOD_SHELL_URL : '/pun/sys/shell/ssh';
}

/**
 * Split a delimited string into ssh_host, host_name objects
 *
 * Gracefully handles nulls, empty strings and incomplete pairs by not
 * returning an element for those cases.
 *
 *   var hosts = 'owens.osc.edu:Owens,ruby.osc.edu:Ruby,pitzer.osc.edu:Pitzer'
 *   sshHosts(hosts) === [
 *       {ssh_host: 'owens.osc.edu', host_name: 'Owens'},
 *       {ssh_host: 'ruby.osc.edu', host_name: 'Ruby'},
 *       {ssh_host: 'pitzer.osc.edu', host_name: 'Pitzer'}
 *   ]
 *
 *   sshHosts(null) === []
 *   sshHosts(' ') === []
 *   sshHosts('a:b,c') === [{ssh_host: 'a', host_name: 'b'}]
 *
 * Overrides OOD_SHELL
 *
 * @param      {String}  hosts   The unparsed host list
 * @return     {Array<Object>}  An array of ssh_host, host_name objects
 */
function sshHosts(hosts) {
    return (hosts || '').split(',').map(function(el) {
        var split = el.split(':')

        if(split.length !== 2) {
            return false
        }

        return {
            ssh_host:  split[0],
            host_name: split[1]
        };
    }).filter(el => el);
}

var whitelist = {
    paths:  process.env.WHITELIST_PATH ? process.env.WHITELIST_PATH.split(":") : [],
    enabled: function(){ return this.paths.length > 0; },
    contains: function(filepath){
        return this.paths.filter(function(whitelisted_path){
            // path.relative will contain "/../" if not in the whitelisted path
            return ! path.relative(
                expandTilde(whitelisted_path),
                resolvePath(filepath)
            ).split(
                path.sep
            ).includes(
                ".."
            );
        }).length > 0;
    },
    // "/api/v1/mv", "/api/v1/cp" are handled by the lib/cloudcmd server itself
    // FIXME: its possible that ALL reads can be handled in a similar way by the server itself
    requests: ["/api/v1/mv", "/api/v1/cp", "/cloudcmd.js", "/public/favicon.ico", "/api/v1/config", "/json/modules.json", "/ishtar/ishtar.js", "/remedy/remedy.js"],
    request_prefixes: ["/css", "/join:", "/lib/client", "/img", "/font", "/pun/sys", "/modules", "/tmpl", "/spero"]
};

// Keep app backwards compatible
if (fs.existsSync('.env')) {
    console.warn('[DEPRECATION] The file \'.env\' is being deprecated. Please move this file to \'/etc/ood/config/apps/files/env\'.');
    dotenv.config({path: '.env'});
}

server = http.createServer(app);

// Set up the socket
socket = io.listen(server, {
    path: BASE_URI + '/socket.io'
});

// thank you https://regex101.com/
//
// here are example urls:
//
// url: /api/v1/fs/Users/efranz/Downloads/
// path: /Users/efranz/Downloads/
// rx: ^\/api\/v1\/fs(.*)
//
// url: /api/v1/fs/Users/efranz/Downloads/fascinating.txt?download=1544841048995
// path: /Users/efranz/Downloads/fascinating.txt
// rx: ^\/api\/v1\/fs(.*)
//
// url: /api/v1/fs/Users/efranz/Downloads/IT7.5.1-WIAG.txt?hash
// path: /Users/efranz/Downloads/IT7.5.1-WIAG.txt
//
// url: /oodzip/Users/efranz/Downloads/gs
// path: /Users/efranz/Downloads/gs
//
// url: /fs/Applications/
// path: /Applications/
if(whitelist.enabled()) {
    app.use(function(req, res, next) {
        var request_url = url.parse(req.url).pathname,
            rx = /(?:\/oodzip|\/api\/v1\/fs|\/fs)(.*)(?:)/,
            match,
            filepath;

        if(BASE_URI && BASE_URI != "/")
            request_url = request_url.replace(BASE_URI, '');

        match = request_url.match(rx);
        filepath = match ? match[1] : null;

        if(request_url == "/" || request_url == "/fs"){
            filepath = "/";
        }


        if(filepath != null && whitelist.contains(filepath)) {
            next();
        }
        else if(whitelist.requests.includes(request_url)){
            next();
        }
        else if(startsWithAny(request_url, whitelist.request_prefixes)){
          next();
        }
        else{
            res.status(403).send("Forbidden").end();
        }
    });
}

// Disable browser-side caching of assets by injecting expiry headers into all requests
// Since the caching is being performed in the browser, we set several headers to
// get the client to respect our intentions.
app.use(function(req, res, next) {
    res.header('Cache-Control', 'private, no-cache, must-revalidate');
    res.header('Expires', '-1');
    next();
});

// This is a custom middleware to work around Passenger filling up /tmp with the download buffer.
// nginx-stage sets the X-Sendfile-Type and X-Accel-Mapping headers, which are used to redirect
//  to the download api configured by nginx-stage and force nginx transfer instead of Passenger.
// If the headers are not properly configured, fall back to the default behavior.
app.get(BASE_URI + CloudFunc.apiURL + CloudFunc.FS + ':path(*)', function(req, res, next) {
    var sendfile = req.get('X-Sendfile-Type'),
        mapping  = req.get('X-Accel-Mapping'),
        path     = req.params.path,
        pattern,
        redirect;
    // If nginx stage has properly set the headers, redirect the download.
    if (sendfile && mapping && req.query.download) {
        // generate redirect uri from file path
        mapping = mapping.split('=');
        pattern = '^' + mapping[0];
        redirect = path.replace(new RegExp(pattern), mapping[1]);

        // send attachment with redirect
        res.attachment(path);
        res.set(sendfile, redirect);
        res.end();
    // If a download is requested but the headers are not appropriately set, fall back to this block.
    } else if (req.query.download) {
        // IE Fix for installations without the nginx stage X-Sendfile modifications
        res.set('Content-Disposition', 'attachment');
        next();
    } else {
        next();
    }
});

// Custom middleware to zip and send a directory to a browser.
// Access at http://PREFIX/oodzip/PATH
// Uses `archiver` https://www.npmjs.com/package/archiver to stream the contents of a file to the browser.
// FIXME: Can we do app.get(BASE_URI + "oodzip" + ':path(*)', function(req, res, next))
app.use(function (req, res, next) {
    var paramPath,
        paramURL    = queryString.unescape(req.url);

    // Remove the prefix to isolate the requested path.
    if (paramURL[0] === '/')
        paramPath = paramURL.replace(BASE_URI, '');

    // If the requested path begins with '/oodzip', send the contents as zip
    if (/^\/oodzip/.test(paramPath)) {
        paramPath = paramPath.replace('/oodzip', '');
        var fileinfo;

        // Create and send the archive
        try {
            fileinfo = fs.lstatSync(paramPath);
            if (fileinfo.isDirectory()) {

                var archive     = archiver('zip', {
                    store: true
                });
                var fileName    = path.basename(paramPath) + ".zip";
                var output      = res.attachment(fileName);

                output.on('close', function () {
                    // Uncomment for logging
                    // console.log(archive.pointer() + ' total bytes');
                    // console.log('archiver has been finalized and the output file descriptor has closed.');
                });

                archive.on('error', function(err){
                    throw err;
                });

                archive.pipe(output);
                archive.directory(paramPath, '');
                archive.finalize();

            } else {
                // Not a directory
                next();
            }
        } catch (error) {
            res.send(error);
        }
    } else {
        next();
    }
});

// Load cloudcmd
app.use(cloudcmd({
    socket: socket,                   /* used by Config, Edit (optional) and Console (required)   */
    config: {                         /* config data (optional)                                   */
        auth: false,                  /* this is the default setting, but using it here to reset  */
        showKeysPanel: false,         /* disable the buttons at the bottom of the view            */
        root: '/',                    /* set the root path. change to HOME to use homedir         */
        prefix: BASE_URI,             /* base URL or function which returns base URL (optional)   */

        //TODO: could we set this using get params? or post params for when you first "create a session" ?
        //FIXME: try setting this with get params - or something that will make
        // each app instance have a separate treeroot
        // treeroot: "/nfs/gpfs/PZS0530",
        // treeroottitle: "Project Space"
        treeroot:               HOME,
        treeroottitle:          "Home Directory",
        upload_max:             process.env.FILE_UPLOAD_MAX || 10485760000,
        file_editor:            process.env.OOD_FILE_EDITOR || '/pun/sys/file-editor/edit',
        shell:                  (process.env.OOD_SHELL || process.env.OOD_SHELL === "") ? process.env.OOD_SHELL : '/pun/sys/shell/ssh/default',
        ssh_hosts:              sshAppUrls(sshHosts(process.env.OOD_SSH_HOSTS), oodShellUrl()),
        // function that accepts a path and returns true or false
        // FIXME: whitelist would be better as a function that has some properties!
        whitelist: whitelist.enabled() ? whitelist : null
    }
}));

server.listen(PORT);
