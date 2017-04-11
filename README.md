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

Open a terminal to the default SSH host (`$DEFAULT_SSHHOST` or `localhost`):

`http://localhost:3000/`

To specify the host:

`http://localhost:3000/ssh/<host>`

To specify a directory on the default host:

`http://localhost:3000/ssh/default/dir`

To specify a host and directory:

`http://localhost:3000/ssh/<host>/<dir>`

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/OSC/ood-shell.


## License

The gem is available as open source under the terms of the [MIT
License](http://opensource.org/licenses/MIT).
