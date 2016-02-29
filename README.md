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

Be sure to modify the `PREFIX` var to the hosted prefix of the app.

Ex. `/pun/shared/bmcmichael` if deploying to the shared environment.

# add `package.json`
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
    "cloudcmd": "^5.1.5",
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

The app.json currently uses hardcoded version dependencies. The node versioning system allows Major, Minor, and Patch level versioning updates (like bundler), but this is all in such a state of flux right now.

### Install dependencies

Use `npm` to install the dependencies defined in the `package.json`

```
$ npm i
```

### Remove undesirable features

Find and remove the following lines from `node_modules/cloudcmd/html/index.html`

```
<button id=~       class="cmd-button reduce-text icon-console"   title="Console"         >~</button>
<button id=contact class="cmd-button reduce-text icon-contact"   title="Contact"         ></button>
```

### Add wetty link

Add this line to the bottom of the button list `node_modules/cloudcmd/html/index.html`

```
<a href="http://websvcs08.osc.edu:5000/pun/shared/jnicklas/wetty/ssh/" target="_blank"><button id=wetty class="cmd-button reduce-text icon-console" title="Wetty">~</button></a>
```