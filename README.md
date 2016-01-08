# NginxStage

Stage and control per-user NGINX processes. Only relies on Ruby core and
standard libraries making installation a breeze.

## Installation

1. Clone this repo into a standard location

    ```
    git clone <repo> /path/to/nginx_stage
    ```

2. Modify permissions for `root`

    ```
    sudo chown -R root:root /path/to/nginx_stage
    sudo chmod -R u+rwX,go+rX,go-w /path/to/nginx_stage
    ```

3. Create the following directories `root` owned

    ```
    sudo mkdir /var/log/nginx -m 755
    sudo mkdir /var/run/nginx -m 755
    sudo mkdir /var/tmp/nginx -m 755
    sudo mkdir /tmp/nginx -m 755
    ```

    Confirm there were no errors due to pre-existing directories.

4. Add or confirm that the `httpd` reverse proxy user (i.e., `apache`) is in
   the group `apache`. This will give them access to connect to the per-user
   NGINX unix domain sockets.

5. Give the `httpd` reverse proxy user (i.e., `apache`) `sudo` privileges to
   run:

    ```
    /path/to/nginx_stage/sbin/nginx_stage
    ```

6. If a **very trusted** developer wants to work on `nginx_stage` give them
   `sudo` privileges to run:

    ```
    /path/to/nginx_stage/sbin/nginx_stage_dev
    ```

## Usage

```shell
$ sudo nginx_stage --help
Usage: nginx_stage COMMAND --user=USER [OPTIONS]

Commands:
 pun      # Generate a new per-user nginx config and process
 app      # Generate a new nginx app config and reload process

Required options:
    -u, --user=USER                  # The USER running the per-user nginx process

Pun options:
    -s, --signal=SIGNAL              # Send SIGNAL to per-user nginx process: stop/quit/reopen/reload

App options:
    -r, --request=REQUEST            # The REQUEST uri accessed

Common options:
    -N, --[no-]skip-nginx            # Skip executing the per-user nginx process
    -h, --help                       # Show this help message
    -v, --version                    # Show version

...
```

#### Examples

To generate a per-user nginx environment & launch nginx:

    nginx_stage pun --user=bob

To stop the above nginx process:

    nginx_stage pun --user=bob --signal=stop

To generate ONLY the per-user nginx environment:

    nginx_stage pun --user=bob --skip-nginx

To generate an app config from a URI request and reload the nginx process:

    nginx_stage app --user=bob --request=/pun/shared/jimmy/fillsim/container/13

To generate ONLY the app config from a URI request:

    nginx_stage app --user=bob --request=/pun/shared/jimmy/fillsim --skip-nginx


## Contributing

1. Fork it ( https://github.com/[my-github-username]/nginx_stage/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request