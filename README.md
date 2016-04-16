# ood-portal-generator

Generates an Open OnDemand portal config for an Apache server.

## Requirements

### Generate OOD Portal config

- Ruby 1.9 or newer

### Run OOD Portal config

- Apache httpd 2.4 ([Documentation](https://httpd.apache.org/docs/2.4/))
- mod_ood_proxy (and its requirements) ([Documentation](https://code.osu.edu/open-ondemand/mod_ood_proxy))
- mod_env ([Documentation](https://httpd.apache.org/docs/2.4/mod/mod_env.html))
- mod_lua ([Documentation](https://httpd.apache.org/docs/2.4/mod/mod_lua.html))
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

2.  Build the Apache config from **environment variables** outlined below. To
    use the defaults:

    ```bash
    # Generate Apache config in `/build`
    rake

    # If using Software Collections, set Ruby environment
    #scl enable rh-ruby22 -- rake
    ```

    To modify any configuration options from the default, run it as

    ```bash
    # Generate Apache config in `/build`
    rake OOD_PUBLIC_ROOT='/var/www/docroot' OOD_PUBLIC_URI='/public'

    # If using Software Collections, set Ruby environment
    #scl enable rh-ruby22 -- rake OOD_AUTH_TYPE='openid-connect'
    ```

3.  Verify that the Apache config file is generated correctly in

    ```
    build/ood-portal.conf
    ```

4.  Install the Apache config that defines the OOD portal

    ```bash
    # Install Apache config in default PREFIX
    sudo rake install

    # Using Software Collections, use this instead
    #sudo scl enable rh-ruby22 -- rake install
    ```

    The default install location is

    ```
    /opt/rh/http24/root/etc/httpd/conf.d
    ```

    To change this run


    ```bash
    # Install Apache config in different PREFIX
    sudo rake install PREFIX='/etc/httpd/conf.d'
    ```

## Rake Tasks

To view the available rake tasks you'd run:

```bash
# List available rake tasks
rake -T

# Using Software Collections, use this instead
#scl enable rh-ruby22 -- rake -T
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

# Subdomain used for the Open OnDemand portal
# Blank: Remove `ServerName` directive
#
OOD_SUBDOMAIN=''

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
```
## Configuration File

If you don't find the default options or setting environment variables
satisfactory, then you can specify the configuration options in `config.rake`
as such

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
