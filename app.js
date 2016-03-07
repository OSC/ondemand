var http        = require('http'),
    cloudcmd    = require('cloudcmd'),
    express     = require('express'),
    io          = require('socket.io'),
    HOME        = require('os-homedir')(),
    app         = express(),
    dirArray    = __dirname.split('/'),
    PORT        = 9001,
    PREFIX      = '',
    server,
    socket;

// Remap prefixes for dev and shared environments
var appName = dirArray[dirArray.length-1];
if (dirArray.indexOf("ood_dev") > -1) {
    PREFIX = "/pun/dev/" + appName;
} else if (dirArray.indexOf("ood_shared") > -1) {
    var appHostUser = dirArray[dirArray.indexOf("ood_shared") - 1];
    PREFIX = "/pun/shared/" + appHostUser + "/" + appName;
}

server = http.createServer(app);

// Set up the socket
socket = io.listen(server, {
    path: PREFIX + '/socket.io'
});

// Load cloudcmd
app.use(cloudcmd({
    socket: socket,                   /* used by Config, Edit (optional) and Console (required)   */
    config: {                         /* config data (optional)                                   */
        auth: false,                  /* this is the default setting, but using it here to reset  */
        root: '/',                    /* set the root path. change to HOME to use homedir         */
        prefix: PREFIX,               /* base URL or function which returns base URL (optional)   */
    }
}));

 server.listen(PORT);
