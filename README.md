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
