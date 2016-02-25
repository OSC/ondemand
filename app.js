var http        = require('http'),
    cloudcmd    = require('cloudcmd'),
    express     = require('express'),
    io          = require('socket.io'),
    homeDir     = require('os-homedir'),
    app         = express(),
    PORT        = 9001,
    PREFIX      = '/pun/dev/cloudcmd',

    server,
    socket;

server = http.createServer(app);
socket = io.listen(server, {
  path: PREFIX + '/socket.io'
});

app.use(cloudcmd({
    socket: socket,                   /* used by Config, Edit (optional) and Console (required)   */
    config: {                         /* config data (optional)                                   */
      root: homeDir(),  
      prefix: PREFIX,  /* base URL or function which returns base URL (optional)   */
    }
}));

server.listen(PORT);
