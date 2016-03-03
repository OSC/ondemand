var http        = require('http'),
    cloudcmd    = require('cloudcmd'),
    express     = require('express'),
    io          = require('socket.io'),
    HOME        = require('os-homedir')(),
    app         = express(),
    PORT        = 9001,
    PREFIX      = '/pun/dev/cloudcmd',
                                                /* FIXME: Find a way to make this dynamic based on the system
                                                 *        This needs to be updated to ex: 
                                                 *        '/pun/shared/bmcmichael/cloudcmd',
                                                 *        when used on the shared environment.
                                                 */
    server,
    socket;

server = http.createServer(app);

socket = io.listen(server, {
    path: PREFIX + '/socket.io'
});

app.use(cloudcmd({
    socket: socket,                   /* used by Config, Edit (optional) and Console (required)   */
    config: {                         /* config data (optional)                                   */
        auth: false,                  /* this is the default setting, but using it here to reset  */
        root: '/',                    /* set the root path. change to HOME to use homedir         */
        prefix: PREFIX,               /* base URL or function which returns base URL (optional)   */
    }
}));

server.listen(PORT);
