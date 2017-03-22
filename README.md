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

1. Navigate to the app's build directory and check out the latest version.

  ```sh
  cd shell # cd to build directory
  scl enable git19 -- git fetch
  scl enable git19 -- git checkout tags/v1.1.2
  ```

2. Update any required packages:

  ```sh
  scl enable nodejs010 -- npm install
  ```

3. Restart the app

  ```sh
  touch tmp/restart.txt
  ```

4. Copy the built app directory to the deployment directory. There is no need to restart the server. Because we touched `tmp/restart.txt` in the app, the next time a user accesses an app Passenger will reload their app.

  ```sh
  sudo mkdir -p /var/www/ood/apps/sys/shell
  sudo rsync -rlptv --delete . /var/www/ood/apps/sys/shell
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
