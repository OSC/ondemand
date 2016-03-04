# Getting started

```
mkdir cloudcmd
cd cloudcmd
```

Create `app.js` and configure as middleware.

```
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

// Enable CORS for use with OAuth2
// https://www.w3.org/TR/cors/
app.use(function(req, res, next) {
    // FIXME: Should this be "*" ? Can we limit this to only our OAuth provider, or does this refer to any client?
    // http://enable-cors.org/server_expressjs.html
    res.header("Access-Control-Allow-Origin", "*");
    res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
    next();
});

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

### Copy the custom osc code to cloudcmd

```
$ cp -r osc_custom/* node_modules/cloudcmd/
```

Currently, this removes the Contact option and replaces the Console functionality with a link to the Wetty app.

## (Optional) Manual Instructions:

##### Remove undesirable features

Find and remove the following lines from `node_modules/cloudcmd/html/index.html`

```
<button id=~       class="cmd-button reduce-text icon-console"   title="Console"         >~</button>
<button id=contact class="cmd-button reduce-text icon-contact"   title="Contact"         ></button>
```

##### Add wetty link

Add this line with the appropriate to the bottom of the button list at `node_modules/cloudcmd/html/index.html`

```
<a href="http://websvcs08.osc.edu:5000/pun/shared/jnicklas/wetty/ssh/" target="_blank"><button id=wetty class="cmd-button reduce-text icon-console" title="Wetty">~</button></a>
```

##### Disable authentication checkbox

Add `false` and `disabled` to checkbox in `node_modules/cloudcmd/tmpl/config.hbs`

```
<input data-name="js-auth" type="checkbox" false disabled>
```


