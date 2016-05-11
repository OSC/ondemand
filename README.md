# ood-portal-generator

Generates an Open OnDemand portal config for an Apache server.

## Requirements

### Generate OOD Portal config

- Ruby 1.9 or newer

### Run OOD Portal config

- Apache httpd 2.4 or newer (and the following modules)
    - mod_ood_proxy (and its requirements)
        - mod_lua
        - mod_env
        - mod_proxy (mod_proxy_connect + mod_proxy_wstunnel)
        - mod_auth_* (e.g., mod_auth_openidc)

## Installation

1.  Clone/pull this repo onto the local file system
    - first time installation

        ```bash
        git clone <repo> /path/to/repo
        ```
    - updating

        ```bash
        cd /path/to/repo
        git pull
        ```

2.  Checkout a specific version of the `ood-portal-generator`

    ```bash
    git checkout tags/vX.Y.Z
    ```

    where `X.Y.Z` is the version number. For example

    ```bash
    git checkout tags/v1.0.0
    ```

    will checkout `v1.0.0` of the `ood-portal-generator`.

3.  Build the Apache config using the default **environment variables**
    outlined [below](#default-options).

    ```bash
    # Generate Apache config in `/build`
    rake

    # If using Software Collections, set Ruby environment
    #scl enable rh-ruby22 -- rake
    ```

    To modify any configuration options from the default, specify it after the
    `rake` command

    ```bash
    # Generate Apache config in `/build`
    rake OOD_PUBLIC_ROOT='/var/www/docroot' OOD_PUBLIC_URI='/public'

    # If using Software Collections, set Ruby environment
    #scl enable rh-ruby22 -- rake OOD_AUTH_TYPE='openid-connect'
    ```

4.  Verify that the Apache config file is generated correctly in

    ```
    build/ood-portal.conf
    ```

    If you'd like to make a change to the above file, then run

    ```
    # Clean up config file
    rake clean

    # If using Software Collections, set Ruby environment
    #scl enable rh-ruby22 -- rake clean
    ```

    and re-build the config file from step `#3` with the desired configuration
    options.

5.  Install the Apache config that defines the OOD portal

    ```bash
    # Install Apache config in default PREFIX
    sudo rake install

    # Using Software Collections, use this instead
    #sudo scl enable rh-ruby22 -- rake install
    ```

    The default install location is

    ```
    /opt/rh/httpd24/root/etc/httpd/conf.d
    ```

    To change this run


    ```bash
    # Install Apache config in different PREFIX
    sudo rake install PREFIX='/etc/httpd/conf.d'
    ```

## Default Options

The default options used to generate the Apache config are listed below. You
can modify any of these by setting the corresponding environment variable when
calling the `rake` task.

#### Build Options

```bash
# Path for installation in `rake install`
#
PREFIX='/opt/rh/httpd24/root/etc/httpd/conf.d'

# Directory with ERB templates
#
SRCDIR='templates'

# Directory for temporary rendered configs
#
OBJDIR='build'

# Filename of rendered config
#
OBJFILE='ood-portal.conf'
```

#### Server Options

```bash
# IP used for Open OnDemand portal
# Blank: Remove `Listen` & `<VirtualHost>` directives
#
OOD_IP=''

# Port used for Open OnDemand portal
#
OOD_PORT='443'

# Whether SSL is used [Boolean]
#
OOD_SSL='true'

# Whether http traffic is redirected to https [Boolean]
#
OOD_SSL_REDIRECT='true'

# ServerName used for the Open OnDemand portal
#
OOD_SERVER_NAME='www.example.com'

# Type of user authentication used for Open OnDemand portal
#
OOD_AUTH_TYPE='openid-connect'
```

#### System Options

```bash
# Path to the Open OnDemand Lua scripts
# Blank: Remove `LuaRoot` directive
#
OOD_LUA_ROOT='/opt/ood/mod_ood_proxy/lib'

# Command used to stage PUNs
#
OOD_PUN_STAGE_CMD='sudo /opt/ood/nginx_stage/sbin/nginx_stage'

# Maximum number of retries when trying to start the PUN
#
OOD_PUN_MAX_RETRIES='5'

# Command used to map users to system level users
#
OOD_USER_MAP_CMD='/opt/ood/osc-user-map/bin/osc-user-map'

# Path to the root location of PUN socket files
#
OOD_PUN_SOCKET_ROOT='/var/run/nginx'

# Path to publicly available assets
#
OOD_PUBLIC_ROOT='/var/www/docroot/ood/public'
```

#### OOD Portal URIs

```bash
# Reverse proxy to backend PUNs
# Blank: Removes the availability of this URI in the config
#
OOD_PUN_URI='/pun'

# Reverse proxy to backend nodes
# Blank: Removes the availability of this URI in the config
#
OOD_NODE_URI='/node'

# "Relative" reverse proxy to backend nodes
# Blank: Removes the availability of this URI in the config
#
OOD_RNODE_URI='/rnode'

# Control the backend PUN (e.g., start, stop, reload, ...)
# Blank: Removes the availability of this URI in the config
#
OOD_NGINX_URI='/nginx'

# Serve up publicly available assets
# Blank: Removes the availability of this URI in the config
#
OOD_PUBLIC_URI='/public'

# Redirect user to this URI if fail to map to system level user
# Blank: Removes the redirection upon a failed user mapping
#
OOD_MAP_FAIL_URI='/efranz'
```
## Configuration File

If the default options or using environment variables to make changes do not
meet your needs, then you can specify the configuration options in
`config.rake` as such

```ruby
# config.rake

OOD_USER_MAP_COMMAND = '/usr/local/bin/my-usr-map'
OOD_PUBLIC_ROOT = '/var/www/docroot'
```

Options specified in `config.rake` take precendence over the corresponding
environment variable set.

## Version

To list the current version being used when building an OOD Portal config file,
use:

```bash
rake version
```

For individual configs, the version is listed in the header of the file.
