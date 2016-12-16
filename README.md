# OOD Shell

[![GitHub version](https://badge.fury.io/gh/OSC%2Food-shell.svg)](https://badge.fury.io/gh/OSC%2Food-shell)

This app is a Node.js app for Open OnDemand providing a web based terminal
using Chrome OS's hterm. It is meant to be run as the user (and on behalf of
the user) using the app. Thus, at an HPC center if I log into OnDemand using
the `efranz` account, this app should run as `efranz`.

## New Install

1.  Starting in the build directory for all sys apps, clone and check out the
    latest version of the shell app (make sure the app directory's name is
    `shell`):

    ```sh
    git clone https://github.com/OSC/ood-shell.git shell
    cd shell
    git checkout tags/v1.1.1
    ```

3. Install required packages:

    ```sh
    npm install
    ```

4. (Optional) Create a `.env` file specifying the default ssh host (default:
   `localhost`):

    ```sh
    # .env

    DEFAULT_SSHHOST='oakley.osc.edu'
    ```

## Updating to a new stable version

If you update any of the code or environment variables of this app you must
restart the app for all the users by:

```sh
touch tmp/restart.txt
```

## Usage

Assume the base URL for the app is `https://localhost/pun/sys/shell`.

To open a new terminal to default host, go to:

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
