# NginxStage

Stage and control per-user NGINX processes. Only relies on Ruby core and
standard libraries making installation a breeze.

## Requirements

#### RedHat ([Software Collections](https://www.softwarecollections.org/en/))

* [Ruby 2.2](https://www.softwarecollections.org/en/scls/rhscl/rh-ruby22/)
* [nginx 1.6](https://www.softwarecollections.org/en/scls/rhscl/nginx16/)
* [Phusion Passenger 4.0](https://www.softwarecollections.org/en/scls/rhscl/rh-passenger40/)
* [Node.js 0.10](https://www.softwarecollections.org/en/scls/rhscl/nodejs010/)
* [V8 3.14](https://www.softwarecollections.org/en/scls/rhscl/v8314/)

## Installation

1. Clone/pull this repo onto the local file system
    * first time installation

        ```
        git clone <repo> /path/to/repo
        ```
    * updating

        ```
        cd /path/to/repo
        git pull
        ```

2. Install a specific version in default location

    ```
    cd /path/to/repo
    git checkout tags/vX.Y.Z
    sudo rake install
    ```

    this will install the specifed version `X.Y.Z` in `/opt/ood/nginx_stage`

    Note: Running `sudo` will sanitize your current environment. For the case
    of RHEL using Software Collections it is recommended to load the
    environment inside the `sudo` process:

    ```
    cd /path/to/repo
    git checkout tags/vX.Y.Z
    sudo scl enable rh-ruby22 -- rake install
    ```

    Examples:

    ```
    # Install v1.0.0 of nginx_stage to /opt/ood/nginx_stage
    git checkout tags/v1.0.0
    sudo rake install

    # Install v2.0.0 of nginx_stage to /tmp/nginx_stage-v2.0.0
    git checkout tags/v2.0.0
    sudo rake install PREFIX=/tmp/nginx_stage-v2.0.0
    ```

    **Warning**: This will overwrite git-committed existing files.

3. Confirm that the reverse proxy daemon is running as `apache`

    This will give the daemon-user permission to connect to the per-user NGINX
    unix domain sockets.

4. Add the reverse proxy daemon user to `/etc/sudoers`

    ```
    Defaults:apache     !requiretty, !authenticate

    apache ALL=/opt/ood/nginx_stage/sbin/nginx_stage
    ```

5. If a **very trusted** developer wants to work on `nginx_stage` give that
   user `sudo` privileges for `nginx_stage_dev`

    ```
    Defaults:apache,<user>     !requiretty, !authenticate

    apache ALL=/opt/ood/nginx_stage/sbin/nginx_stage
    <user> ALL=/opt/ood/nginx_stage/sbin/nginx_stage_dev
    ```

    **Warning**: This user must be very trusted! Don't say we didn't warn you.

## Post-installation

After the first-time install you may need to modify both the configuration file
and/or Ruby wrapper script.

### Configuration

After the installation procedure it is recommended you configure `nginx_stage`
for your system. You can do so by modifying:

```
PREFIX/config/nginx_stage.yml
```

For any of the configuration options if not defined they will fall back to
their default values.

### Ruby wrapper

Another file you may need to modify is the Ruby wrapper script found here:

```
PREFIX/bin/ood_ruby
```

The responsibility of the Ruby wrapper script is to load the necessary
environment (e.g., libraries and binary paths) for the Open OnDemand per-user
Nginx process to successfully run under. By default it assumes your environment
is properly loaded in the `sudo` configuration.

**Note:** If you are using Software Collections, it is recommended you
uncomment the code block specified in the script.

## Usage

Note: The `nginx_stage` CLI options can be specified as URL encoded strings to
avoid having to escape special characters in the shell.

```
$ sudo nginx_stage --help
Usage: nginx_stage COMMAND [OPTIONS]

Commands:
 pun            # Generate a new per-user nginx config and process
 app            # Generate a new nginx app config and reload process
 nginx          # Generate/control a per-user nginx process

General options:
    -h, --help                       # Show this help message
    -v, --version                    # Show version

All commands can be run with -h (or --help) for more information.
```

### PUN Command

```
$ sudo nginx_stage pun --help
Usage: nginx_stage pun [OPTIONS]

Required options:
    -u, --user=USER                  # The USER of the per-user nginx process

General options:
    -a, --app-init-uri=APP_INIT_URI  # The user is redirected to the APP_INIT_URI if app doesn't exist
                                     # Default: ''
    -N, --[no-]skip-nginx            # Skip execution of the per-user nginx process
                                     # Default: false

Common options:
    -h, --help                       # Show this help message
    -v, --version                    # Show version

Examples:
    To generate a per-user nginx environment & launch nginx:

        nginx_stage pun --user=bob --app-init-uri='/nginx/init?redir=$http_x_forwarded_escaped_uri'

    this will add a URI redirect if the user accesses an app that doesn't exist.

    To generate ONLY the per-user nginx environment:

        nginx_stage pun --user=bob --skip-nginx

    this will return the per-user nginx config path and won't run nginx. In addition
    it will remove the URI redirect from the config unless we specify `--app-init-uri`.
```

If a user visits a URL and the per-user NGINX config does not find a location
that maps to this URL, it will redirect the user to the relative URI supplied
in `APP_INIT_URI`. If none is supplied, then the user will receive a 503 status
code by the server.

### APP Command

```
$ sudo nginx_stage app --help
Usage: nginx_stage app [OPTIONS]

Required options:
    -u, --user=USER                  # The USER of the per-user nginx process
    -r, --sub-request=SUB_REQUEST    # The SUB_REQUEST that requests the specified app

General options:
    -i, --sub-uri=SUB_URI            # The SUB_URI that requests the per-user nginx
                                     # Default: ''
    -N, --[no-]skip-nginx            # Skip execution of the per-user nginx process
                                     # Default: false

Common options:
    -h, --help                       # Show this help message
    -v, --version                    # Show version

Examples:
    To generate an app config from a URI request and reload the nginx
    process:

        nginx_stage app --user=bob --sub-uri=/pun --sub-request=/usr/jimmy/fillsim/container/13

    To generate ONLY the app config from a URI request:

        nginx_stage app --user=bob --sub-uri=/pun --sub-request=/usr/jimmy/fillsim --skip-nginx

    this will return the app config path and won't run nginx.
```

The format of the `SUB_REQUEST` when building an app config is different
depending on whether the `USER` is accessing a sandbox app or a user app.

* **sandbox** app (needs to know the `USER` of the sandbox app)

    ```
    /dev/<app>/*
    ```

    serves up the app in

    ```
    ~USER/ood_dev/<app>
    ```

* **user** app

    ```
    /usr/<owner>/<app>/*
    ```

    serves up the app in

    ```
    ~<owner>/ood_usr/<app>
    ```

Any remaining structure appended to the sub-request URI is ignored when
building the app config.

The `SUB_URI` corresponds to any reverse proxy specific namespace that denotes
the request should be proxied to the backend per-user NGINX server.

### NGINX Command

```
$ sudo nginx_stage nginx --help
Usage: nginx_stage nginx [OPTIONS]

Required options:
    -u, --user=USER                  # The USER of the per-user nginx process

General options:
    -s, --signal=SIGNAL              # Send SIGNAL to per-user nginx process: stop/quit/reopen/reload
                                     # Default: none
    -N, --[no-]skip-nginx            # Skip execution of the per-user nginx process
                                     # Default: false

Common options:
    -h, --help                       # Show this help message
    -v, --version                    # Show version

Examples:
    To stop Bob's nginx process:

        nginx_stage nginx --user=bob --signal=stop

    which sends a `stop` signal to Bob's per-user NGINX process.

    If `--skip-nginx` is supplied it returns the system-level command
    that would have been called.
```

The `SIGNAL` is what is sent to the per-user NGINX process for the specified
user. If no signal is specified, it will try to start the NGINX process.

### Directory Structure

The following paths are created on demand:

```
/var                                    # drwxr-xr-x root   root
├── lib                                 # drwxr-xr-x root   root
│   └── nginx                           # drwxr-xr-x root   root
│       └── config                      # drwxr-xr-x root   root
│           ├── apps                    # drwxr-xr-x root   root
│           │   ├── dev                 # drwxr-xr-x root   root
│           │   │   └── <user>          # drwxr-xr-x root   root
│           │   │       └── <app>.conf  # -rw-r--r-- root   root
│           │   └── usr                 # drwxr-xr-x root   root
│           │       └── <user>          # drwxr-xr-x root   root
│           │           └── <app>.conf  # -rw-r--r-- root   root
│           └── puns                    # -rw-r--r-- root   root
│               └── <user>.conf         # -rw-r--r-- root   root
├── log                                 # drwxr-xr-x root   root
│   └── nginx                           # drwxr-xr-x root   root
│       └── <user>                      # drwxr-xr-x root   root
│           ├── access.log              # -rw-r--r-- root   root
│           └── error.log               # -rw-r--r-- root   root
└── run                                 # drwxr-xr-x root   root
    └── nginx                           # drwxr-xr-x root   root
        └── <user>                      # drwx------ apache root
            ├── passenger.pid           # -rw-r--r-- root   root
            └── passenger.sock          # srw-rw-rw- root   root

~<user>                                 # drwxr-xr-x USER   GROUP
└── .nginx                              # drwxr-xr-x USER   GROUP
    ├── client_body                     # drwx------ USER   root
    ├── fastcgi_temp                    # drwx------ USER   root
    ├── proxy_temp                      # drwx------ USER   root
    ├── scgi_temp                       # drwx------ USER   root
    └── uwsgi_temp                      # drwx------ USER   root
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/nginx_stage/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
