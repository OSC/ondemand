var http        = require('http'),
    cloudcmd    = require('cloudcmd'),
    express     = require('express'),
    io          = require('socket.io'),
    HOME        = require('os-homedir')(),
    BASE_URI    = require('base-uri'),
    app         = express(),
    dirArray    = __dirname.split('/'),
    PORT        = 9001,
    PREFIX      = '',
    server,
    socket;

server = http.createServer(app);

// Set up the socket
socket = io.listen(server, {
    path: BASE_URI + '/socket.io'
});

// Disable browser-side caching of assets by injecting expiry headers into all requests
// Since the caching is being performed in the browser, we set several headers to
// get the client to respect our intentions.
app.use(function(req, res, next) {
    res.header('Cache-Control', 'private, no-cache, no-store, must-revalidate');
    res.header('Expires', '-1');
    res.header('Pragma', 'no-cache');
    next();
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
        treeroot: HOME,
        treeroottitle: "Home Directory",

        file_editor: "/pun/sys/file-editor/edit",
        shell: "/pun/sys/shell/ssh/oakley"
    }
}));

server.listen(PORT);
