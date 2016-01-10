# NginxStage

Stage and control per-user NGINX processes. Only relies on Ruby core and
standard libraries making installation a breeze.

## Installation

1. Clone this repo into a standard location

    ```
    git clone <repo> /opt/ood/nginx_stage
    ```

2. Modify permissions for `root`

    ```
    sudo chown -R root:root /opt/ood/nginx_stage
    sudo chmod -R u+rwX,go+rX,go-w /opt/ood/nginx_stage
    ```

3. Add or confirm that the reverse proxy daemon user is in the group `apache`

    ```
    # Add reverse proxy daemon user to group `apache`
    ```

    This will give the daemon user permissions to connect to the per-user NGINX
    unix domain sockets.

4. Give the reverse proxy daemon user `sudo` privileges to run the following
   binary

    ```
    /opt/ood/nginx_stage/sbin/nginx_stage
    ```

5. If a **very trusted** developer wants to work on `nginx_stage` give them
   `sudo` privileges to run the following binary

    ```
    /opt/ood/nginx_stage/sbin/nginx_stage_dev
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

#### Sub-Request URI

The format of the `SUB_REQUEST` when building an app config is different
depending on whether the `USER` is accessing a sandbox app or a shared app.

* **sandbox** app (needs to know the `USER` of the sandbox app)

    ```
    /dev/<app>/*
    ```

    serves up the app in

    ```
    ~USER/ood_dev/<app>
    ```

* **shared** app

    ```
    /shared/<owner>/<app>/*
    ```

    serves up the app in

    ```
    ~<owner>/ood_shared/<app>
    ```

Any remaining structure appended to the sub-request URI is ignored when
building the app config.

#### Examples

To generate a per-user nginx environment & launch nginx:

    nginx_stage pun --user=bob

To stop the above nginx process:

    nginx_stage pun --user=bob --signal=stop

To generate ONLY the per-user nginx environment:

    nginx_stage pun --user=bob --skip-nginx

To generate an app config from a URI request and reload the nginx process:

    nginx_stage app --user=bob --sub-uri=/pun --sub-request=/shared/jimmy/fillsim/container/13

To generate ONLY the app config from a URI request:

    nginx_stage app --user=bob --sub-uri=/pun --sub-request=/shared/jimmy/fillsim --skip-nginx

#### Directory Structure

The following paths are created on demand:

```
/var/rw                                 # drwxr-xr-x root root
├── lib                                 # drwxr-xr-x root root
│   └── nginx                           # drwxr-xr-x root root
│       ├── config                      # drwxr-xr-x root root
│       │   ├── dev                     # drwxr-xr-x root root
│       │   │   └── <user>              # drwxr-xr-x root root
│       │   │       └── <dev_app>.conf  # -rw-r--r-- root root
│       │   ├── shared                  # drwxr-xr-x root root
│       │   │   └── <user>              # drwxr-xr-x root root
│       │   │       └── <app>.conf      # -rw-r--r-- root root
│       │   └── <user>.conf             # -rw-r--r-- root root
│       └── tmp                         # drwxr-xr-x root root
│           └── <user>                  # drwxr-xr-x root root
│               ├── client_body         # drwx------ USER root
│               ├── fastcgi_temp        # drwx------ USER root
│               ├── proxy_temp          # drwx------ USER root
│               ├── scgi_temp           # drwx------ USER root
│               └── uwsgi_temp          # drwx------ USER root
├── log                                 # drwxr-xr-x root root
│   └── nginx                           # drwxr-xr-x root root
│       └── <user>                      # drwxr-xr-x root root
│           ├── access.log              # -rw-r--r-- root root
│           └── error.log               # -rw-r--r-- root root
└── run                                 # drwxr-xr-x root root
    └── nginx                           # drwxr-x--- root apache
        ├── <user>.pid                  # -rw-r--r-- root root
        └── <user>.sock                 # srw-rw-rw- root root
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/nginx_stage/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
