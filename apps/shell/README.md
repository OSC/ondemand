# OOD Shell

![GitHub Release](https://img.shields.io/github/release/osc/ood-shell.svg)
![GitHub License](https://img.shields.io/github/license/osc/ood-shell.svg)

This app is a Node.js app for Open OnDemand providing a web based terminal
using Chrome OS's hterm. It is meant to be run as the user (and on behalf of
the user) using the app. Thus, at an HPC center if I log into OnDemand using
the `ood` account, this app should run as `ood`.

## New Install

1.  Start in the **build directory** for all sys apps, clone and check out the
    latest version of the shell app (make sure the app directory's name is
    `shell`):

    ```sh
    scl enable rh-git29 -- git clone https://github.com/OSC/ood-shell.git shell
    cd shell
    scl enable rh-git29 -- git checkout tags/v1.4.2
    ```

2.  Install the app:

    ```sh
    scl enable rh-git29 rh-ruby24 rh-nodejs6 -- bin/setup
    ```

3.  Copy the built app directory to the deployment directory, and start the
    server. i.e.:

    ```sh
    sudo mkdir -p /var/www/ood/apps/sys
    sudo cp -r . /var/www/ood/apps/sys/shell
    ```

## Updating to a New Stable Version

1.  Navigate to the app's build directory and check out the latest version:

    ```sh
    cd shell # cd to build directory
    scl enable rh-git29 -- git fetch
    scl enable rh-git29 -- git checkout tags/v1.4.2
    ```

2.  Update the app:

    ```sh
    scl enable rh-git29 rh-ruby24 rh-nodejs6 -- bin/setup
    ```

3.  Copy the built app directory to the deployment directory:

    ```sh
    sudo rsync -rlptv --delete . /var/www/ood/apps/sys/shell
    ```

## Configuration

The app can be configured by editing the global environment file:

```
/etc/ood/config/apps/shell/env
```

An example environment file is:

```sh
# /etc/ood/config/apps/shell/env

# The default ssh host the user is logged into if the user doesn't specify a
# host in the url
DEFAULT_SSHHOST="localhost"
```

## Usage

Open a terminal to the default SSH host:

`http://localhost:3000/`

To specify the host:

`http://localhost:3000/ssh/<host>`

To specify a directory on the default host:

`http://localhost:3000/ssh/default/<dir>`

To specify a host and directory:

`http://localhost:3000/ssh/<host>/<dir>`

## Terminal Color Themes

Color Themes from https://github.com/mbadolato/iTerm2-Color-Schemes:

- windowsterminal themes used (since they are JSON format) with "cursorColor": specified
- renamed Builtin Pastel Dark to Pastel Dark
- renamed Builtin Solarized Light to Solarized Light
- see [iTerm-Color-Schemes](https://github.com/mbadolato/iTerm2-Color-Schemes) for access to individual theme licenses

## Development

For development purposes the environment variables must be specified in the
local environment file:

```
.env.local
```

underneath the root directory of this app in your sandbox.

To mimic the production environment you may have to copy the production
environment variables down or set up a symbolic link:

```sh
# Copy production env vars
cp /etc/ood/config/apps/shell/env .env.local

# or setup a symlink
ln -s /etc/ood/config/apps/shell/env .env.local
```

Any changes made to the environment files require an app restart in order for
the changes to take effect:

```console
$ touch tmp/restart.txt
```

### Updating `hterm`

Clone Google's repository that includes some other things in addition to hterm:

```console
$ git clone https://chromium.googlesource.com/apps/libapps
```

Run the build script. It requires Python, specifically Python 3 for hterm 1.81 and newer. Here, it is run from the root directory of this new local repository (libapps):

```console
$ scl enable rh-python35 -- hterm/bin/mkdist.sh
```

There will be a file created in `hterm/dist/js` called `hterm_all.js`. Copy and rename this file to `public/javascripts/hterm_all_x.xx.js` in the Shell App repository, where x.xx represents the version number hterm (for cache busting), and change the reference in `views/index.hbs` to point to this new file.

#### Hacking `hterm`

So you've updated hterm and now something is broken.  Maybe only on one platform (*cough firefox*).  Here's a list of hacks/changes we've made to these files so when you're updating from one version to another you may have to add these 
changes. If you're lucky you may be able to cherry pick them, if not, hopefully we've made an issue where you can reference and you can at least see the commit. 

* 0cbc84e3d53386064e278a0495c940a217f4f18b - that fixed [issue 64](https://github.com/OSC/ood-shell/issues/64)
* a9e2e3980b0f491d0478a20e21aad022285b64ee - that fixed [issue 1214](https://github.com/OSC/ondemand/issues/1214)

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/OSC/ood-shell.

## License

The gem is available as open source under the terms of the [MIT
License](http://opensource.org/licenses/MIT).
