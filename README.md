# OSC Shell

## Install

1.  Clone repo to local directory

    ```
    git clone git@github.com:AweSim-OSC/osc-shell.git osc-shell
    ```

2.  Due to limitations in Node.js installed through RedHat Software Collections,
    we need a newer version of `npm` in order to install this code:

    ```
    mkdir tmp
    scl enable v8314 nodejs010 -- npm install --prefix tmp npm
    ```

3. Install required packages using this newer `npm` package:

    ```
    scl enable v8314 nodejs010 -- tmp/node_modules/.bin/npm install
    ```

4. Create a `.env` file specifying the default ssh host:

    ```
    # .env

    DEFAULT_SSHHOST='oakley.osc.edu'
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
