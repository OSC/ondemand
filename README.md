```
mkdir cloudcmd
cd cloudcmd
npm install --save cloudcmd
npm install --save express
npm install --save socket.io
npm install --save os-homedir
```

Create `app.js` and configure as middleware.

```
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
    socket: socket,                 /* used by Config, Edit (optional) and Console (required)   */
    config: {                       /* config data (optional)                                   */
      root: homeDir(),              /* set the root path to the logged in user's HOME           */
      prefix: PREFIX,               /* base URL or function which returns base URL (optional)   */
    }
}));

server.listen(PORT);
```


package.json
```
{
  "name": "osc-cloudcmd",
  "version": "0.0.1",
  "description": "OSC File Management App",
  "author": "Brian McMichael <bmcmichael@osc.edu>",
  "main": "app.js",
  "repository": {
    "type": "git",
    "url": "Soon"
  },
  "keywords": [
    "file manager",
    "ohio supercomputer center"
  ],
  "dependencies": {
    "cloudcmd": "^5.1.4",
    "express": "^4.13.4",
    "os-homedir": "^1.0.1",
    "socket.io": "^1.4.5"
  },
  "private": true,
  "license": "MIT",
  "scripts": {
    "test": "test"
  }
}
```
