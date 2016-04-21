# OSC Shell

## Install

1.  Clone repo to local directory

    ```
    git clone git@github.com:AweSim-OSC/osc-shell.git osc-shell
    ```

2.  Due to limitations in Node.js installed through RedHat Software Collections,
    we need a newer version of `npm` in order to install this code:

    ```
    mkdir -p ./bin/npm/node_modules
    scl enable v8314 nodejs010 -- npm install --prefix ./bin/npm npm
    ./bin/npm/node_modules/.bin/npm install
    ```

    * You can also install the newer version of npm locally i.e. in your home directory. Then you can do `~/.npm-packages/bin/npm`

3. Install required packages using this newer `npm` package:

    ```
    scl enable v8314 nodejs010 -- node_modules/.bin/npm install
    ```

## Usage

Assume the base URL for the app is /pun/sys/shell.

To open a new terminal to default host (Oakley), go to:

* /pun/sys/shell/ssh or /pun/sys/shell/ssh/default

To specify Oakley or Ruby:

* /pun/sys/shell/ssh/oakley
* /pun/sys/shell/ssh/ruby

To specify another directory besides the home directory to start in, append the
full path of that directory to the URL. In this case, we go to
/nfs/17/efranz/ood_dev:

* /pun/sys/shell/ssh/default/nfs/17/efranz/ood_dev
* /pun/sys/shell/ssh/oakley/nfs/17/efranz/ood_dev
* /pun/sys/shell/ssh/ruby/nfs/17/efranz/ood_dev
