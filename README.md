# OOD Shell

This app is a Node.js app for Open OnDemand providing a web based terminal using Chrome OS's hterm. It is meant to be run as the user (and on behalf of the user) using the app. Thus, at an HPC center if I log into OnDemand using the `efranz` account, this app should run as `efranz`.

## Install

1.  Clone repo to local directory

    ```sh
    git clone git@github.com:OSC/osc-shell.git shell
    ```

2.  Due to limitations in Node.js installed through RedHat Software Collections,
    we need a newer version of `npm` in order to install this code:

    ```sh
    mkdir tmp
    scl enable nodejs010 -- npm install --prefix tmp npm
    ```

3. Install required packages using this newer `npm` package:

    ```sh
    scl enable nodejs010 -- tmp/node_modules/.bin/npm install
    ```

4. (Optional) Create a `.env` file specifying the default ssh host (default:
   `localhost`):

    ```sh
    # .env

    DEFAULT_SSHHOST='oakley.osc.edu'
    ```

## Update

If you update any of the code or environment variables of this app you must
restart the app for all the users by:

```sh
touch tmp/restart.txt
```

## Usage

Assume the base URL for the app is `/pun/sys/shell`.

To open a new terminal to default host (Oakley), go to:

* `/pun/sys/shell/ssh/` or `/pun/sys/shell/ssh/default`

To specify the host:

* `/pun/sys/shell/ssh/<host>`

To specify another directory besides the home directory to start in, append the
full path of that directory to the URL. In this case, we want to navigate to
the path `/path/to/my/directory`:

To open the shell in a specified directory path:

* `/pun/sys/shell/ssh/default/<path>`
* `/pun/sys/shell/ssh/<host>/<path>`
