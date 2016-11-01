var http        = require('http'),
    util        = require('util'),
    fs          = require('fs'),
    path        = require('path'),
    cloudcmd    = require('cloudcmd'),
    CloudFunc   = require('cloudcmd/lib/cloudfunc'),
    express     = require('express'),
    io          = require('socket.io'),
    HOME        = require('os-homedir')(),
    BASE_URI    = require('base-uri'),
    archiver    = require('archiver'),
    queryString = require('querystring'),
    gitSync     = require('git-rev-sync'),
    app         = express(),
    dirArray    = __dirname.split('/'),
    PORT        = 9001,
    PREFIX      = '',
    server,
    socket;

require('dotenv').config();

server = http.createServer(app);

// Set up the socket
socket = io.listen(server, {
    path: BASE_URI + '/socket.io'
});

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

        file_editor:            process.env.OOD_FILE_EDITOR,
        shell:                  process.env.OOD_SHELL,
        fileexplorer_version:   gitSync.tag()
    }
}));

server.listen(PORT);
