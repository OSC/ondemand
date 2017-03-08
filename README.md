# OOD Shell

[![GitHub version](https://badge.fury.io/gh/OSC%2Food-shell.svg)](https://badge.fury.io/gh/OSC%2Food-shell)

This app is a Node.js app for Open OnDemand providing a web based terminal
using Chrome OS's hterm. It is meant to be run as the user (and on behalf of
the user) using the app. Thus, at an HPC center if I log into OnDemand using
the `ood` account, this app should run as `ood`.

## New Install

1.  Start in the **build directory** for all sys apps, clone and check out the
    latest version of the shell app (make sure the app directory's name is
    `shell`):

    ```sh
    scl enable git19 -- git clone https://github.com/OSC/ood-shell.git shell
    cd shell
    scl enable git19 -- git checkout tags/v1.1.2
    ```

2.  Install the required packages:

    ```sh
    scl enable git19 nodejs010 -- npm install
    ```

3.  (Optional) Create a `.env` file specifying the default ssh host (default:
    `localhost`):

    ```sh
    # .env

    DEFAULT_SSHHOST='oakley.osc.edu'
    ```

4. Copy the built app directory to the deployment directory, and start the server. i.e.:

  ```sh
  sudo mkdir -p /var/www/ood/apps/sys
  sudo cp -r . /var/www/ood/apps/sys/shell
  ```

## Updating to a New Stable Version

1.  To update the app you will first go into the build directory from when you
    installed it and fetch the latest changes to the code:

    ```sh
    cd shell
    scl enable git19 -- git fetch
    ```

2.  Determine the latest stable version of this app. At the top of this
    `README.md` you will see it in a green box. Record this `X.X.X` for the
    next step.

3.  Then you will check out the latest stable version of the code that you took
    note of in step 2:

    ```sh
    scl enable git19 -- git checkout tags/vX.X.X
    ```

    Don't forget to replace the `X.X.X` above with what you have from step 2.
    Note that you need the letter `v` preceding the version number.

4.  You will then update any required packages if necessary:

    ```sh
    scl enable nodejs010 -- npm install
    ```

5.  Finally you will force all Passenger instances of this app to restart so
    that the changes are successfully propagated to the users:

    ```sh
    touch tmp/restart.txt
    ```

## Usage

Assume the base URL for the app is `https://localhost/pun/sys/shell`.

To open a new terminal to the default host, go to:

- `https://localhost/pun/sys/shell/ssh/`
- `https://localhost/pun/sys/shell/ssh/default`

To specify the host:

- `https://localhost/pun/sys/shell/ssh/<host>`

To specify another directory besides the home directory to start in, append the
full path of that directory to the URL. In this case, we want to navigate to
the path `/path/to/my/directory`:

To open the shell in a specified directory path:

- `https://localhost/pun/sys/shell/ssh/default/<path>`
- `https://localhost/pun/sys/shell/ssh/<host>/<path>`
