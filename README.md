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
    scl enable rh-git29 -- git checkout tags/v1.3.1
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
    scl enable rh-git29 -- git checkout tags/v1.3.1
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

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/OSC/ood-shell.

## License

The gem is available as open source under the terms of the [MIT
License](http://opensource.org/licenses/MIT).
