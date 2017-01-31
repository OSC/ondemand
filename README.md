# ood-portal-generator

![GitHub Release](https://img.shields.io/github/release/osc/ood-portal-generator.svg)
![GitHub License](https://img.shields.io/github/license/osc/ood-portal-generator.svg)

Generates an Open OnDemand portal config for an Apache server.

## Requirements

### Generate OOD Portal config

- Ruby 1.9 or newer

### Run OOD Portal config

- Apache httpd 2.4.12 or newer (and the following modules)

| **modules required**                               |
| -------------------------------------------------- |
| mod_ood_proxy                                      |
| mod_lua                                            |
| mod_env                                            |
| mod_headers                                        |
| mod_proxy (mod_proxy_connect + mod_proxy_wstunnel) |
| mod_auth_* (e.g., mod_auth_openidc)                |

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
    PREFIX=/opt/rh/httpd24/root/etc/httpd/conf.d
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

# ServerName used for the Open OnDemand portal
#
OOD_SERVER_NAME='www.example.com'

# Any aliases for ServerName that you intend to redirect to the Open OnDemand
# portal
# NB: Must be a colon delimited list of aliases
# Example: 'test1.osc.edu:test2.osc.edu:test3.osc.edu'
# Blank: No alias redirects
OOD_SERVER_ALIASES=''

# Whether we use custom server logs for this server
#
OOD_LOGS='true'

# Whether SSL is used
#
OOD_SSL='true'

# Whether http traffic is redirected to https
#
OOD_SSL_REDIRECT='true'

# Path to the SSL certificate file for the server
# Blank: Remove `SSLCertificateFile` directive
#
OOD_SSL_CERT_FILE=''

# Path to the SSL private key file for the server
# Blank: Remove `SSLCertificateKeyFile` directive
#
OOD_SSL_KEY_FILE=''

# Path to the SSL all-in-one file which forms the certificate chain of the
# server certificate
# Blank: Remove `SSLCertificateChainFile` directive
#
OOD_SSL_CHAIN_FILE=''
```

#### System Options

```bash
# Path to the Open OnDemand Lua scripts
# Blank: Remove `LuaRoot` directive
#
OOD_LUA_ROOT='/opt/ood/mod_ood_proxy/lib'

# Log level used for Lua scripts when logging their output
# NB: https://httpd.apache.org/docs/2.4/mod/core.html#loglevel
# Blank: Remove `LogLevel` directive
#
OOD_LUA_LOG_LEVEL='info'

# Command used to stage PUNs
#
OOD_PUN_STAGE_CMD='sudo /opt/ood/nginx_stage/sbin/nginx_stage'

# Maximum number of retries when trying to start the PUN
#
OOD_PUN_MAX_RETRIES='5'

# Command used to map users to system level users
#
OOD_USER_MAP_CMD='/opt/ood/ood_auth_map/bin/ood_auth_map.regex'

# Path to the root location of PUN socket files
#
OOD_PUN_SOCKET_ROOT='/var/run/nginx'

# Path to publicly available assets
#
OOD_PUBLIC_ROOT='/var/www/docroot/ood/public'

# Regular expression used to parse host from URI used when reverse proxying to
# a backend node (see: OOD_NODE_URI and OOD_RNODE_URI)
# Note: To keep all proxying to within your domain, set it to
#     '[\w.-]+\.domain\.edu'
# Blank: Matches any characters other than forward slash (Default: '[^/]+')
```

#### OOD Portal URIs

```bash
# Reverse proxy to backend PUNs
# Blank: Removes the availability of this URI in the config
#
OOD_PUN_URI='/pun'

# Reverse proxy to backend nodes
# This is used by web apps that allow their sub-uri to be modified so that it
# matches the # front-facing sub-uri
# Note: To provide support for proxying to backend compute nodes it is best to
# enable this as "/node"
# Blank: Removes the availability of this URI in the config
#
OOD_NODE_URI=''

# "Relative" reverse proxy to backend nodes
# This is used by web apps that *only* use relative URL links in their code
# Note: To provide support for proxying to backend compute nodes it is best to
# enable this as "/rnode"
# Blank: Removes the availability of this URI in the config
#
OOD_RNODE_URI=''

# Control the backend PUN (e.g., start, stop, reload, ...)
# Blank: Removes the availability of this URI in the config
#
OOD_NGINX_URI='/nginx'

# Serve up publicly available assets
# Blank: Removes the availability of this URI in the config
#
OOD_PUBLIC_URI='/public'

# Redirect root URI "/" to this URI
# Blank: Removes this redirection
#
OOD_ROOT_URI='/pun/sys/dashboard'
```

#### OOD Analytics Options

It is highly recommended you enable analytics reporting to help further improve
the Open OnDemand project. This can be enabled by specifying the environment
variable:

```bash
export OOD_ANALYTICS_OPT_IN='true'
```

The options set are:

```bash
# Whether you want to opt in to analytics reporting
# Default: 'false'
#
OOD_ANALYTICS_OPT_IN='false'

# The URL used that analytics reporting is sent to
#
OOD_ANALYTICS_TRACKING_URL='http://www.google-analytics.com/collect'

# The analytics reporting id
#
OOD_ANALYTICS_TRACKING_ID='UA-79331310-4'
```

## OOD Authentication Options

### Default Authentication Setup

This uses Apache Basic Auth as the default authentication mechanism:

```bash
# Type of user authentication used for Open OnDemand portal
#
OOD_AUTH_TYPE='Basic'

# Any extended authentication Apache directives separated by newlines
# Example: OOD_AUTH_EXTEND='AuthName "private"\nAuthBasicProvider ldap\nAuthLDAPURL ldap://ldap.host/o=ctx'
# Blank: No extended directives will be added to the config
#
OOD_AUTH_EXTEND='AuthName "private"\nAuthUserFile "/opt/rh/httpd24/root/etc/httpd/.htpasswd"'

# Redirect user to this URI if fail to map to system level user
# Blank: Removes the redirection upon a failed user mapping
#
OOD_MAP_FAIL_URI=''

# Redirect URI for OpenID Connect client
# Blank: Removes the availability of this URI in the config
#
OOD_AUTH_OIDC_URI=''

# URI to access OpenID Connect discovery page
# Blank: Removes the availability of this URI in the config
#
OOD_AUTH_DISCOVER_URI=''

# Path to OpenID Connect discovery page directory
#
OOD_AUTH_DISCOVER_ROOT='/var/www/ood/discover'

# URI to access the user mapping registration page
# Blank: Removes the availability of this URI in the config
#
OOD_AUTH_REGISTER_URI=''

# Path to the user mapping registration page directory
#
OOD_AUTH_REGISTER_ROOT='/var/www/ood/register'

# Whether you want to use CILogon authentication
# Default: 'false'
#
OOD_AUTH_CILOGON='false'
```

The default location for the `.htpasswd` file is:

```
# Assumes you are using RH Software Collections
/opt/rh/httpd24/root/etc/httpd/.htpasswd
```

After the Open OnDemand Portal is deployed and you access the server from your
browser, you will be presented with an authentication dialog box. Currently
there are no accounts specified in the `.htpasswd` file, so you will need to
add a few accounts first:

```
# First we create the password file
scl enable httpd24 -- htpasswd -c /opt/rh/httpd24/root/etc/httpd/.htpasswd <username>

# Afterwards we add accounts to the file
scl enable httpd24 -- htpasswd /opt/rh/httpd24/root/etc/httpd/.htpasswd <another username>
```

If you continue to use Basic Auth, we recommend using the LDAP module.

### Shibboleth Authentication Setup (recommended)

*Work in progress*

Assumes you have a Shibboleth IdP already deployed and setup.

Requirements:

- mod_shib_24

You can then build a portal config as:

```bash
rake OOD_AUTH_TYPE='shibboleth' OOD_AUTH_EXTEND='ShibRequestSetting requireSession 1\nRequestHeader edit* Cookie "(^_shibsession_[^;]*(;\s*)?|;\s*_shibsession_[^;]*)" ""\nRequestHeader unset Cookie "expr=-z %{req:Cookie}"'
```

You will then need an appropriate Apache config that specifies the global
`mod_shib_24` settings you want. An example of such is given here:

```
# /path/to/httpd/conf.d/auth_shib.conf

#
# Turn this on to support "require valid-user" rules from other
# mod_authn_* modules, and use "require shib-session" for anonymous
# session-based authorization in mod_shib.
#
ShibCompatValidUser On

#
# Ensures handler will be accessible.
#
<Location /Shibboleth.sso>
  AuthType None
  Require all granted
</Location>

#
# Used for example style sheet in error templates.
#
<IfModule mod_alias.c>
  <Location /shibboleth-sp>
    AuthType None
    Require all granted
  </Location>
  Alias /shibboleth-sp/main.css /usr/share/shibboleth/main.css
</IfModule>
```

Note: You must have the setting `ShibCompatValidUser On` for authentication to
be handled correctly.

### CILogon Authentication Setup (expert)

Requirements:

- mod_auth_openidc v2.0.0+ / CILogon client information
- ood_auth_discovery (PHP scripts)
- ood_auth_registration (PHP scripts)
- ood_auth_map (ruby CLI script)
- mapdn (also relevant python scripts)

This authentication mechanism takes advantage of:

- `mod_auth_openidc` for the authentication handler in Apache
- CILogon for the OpenID Connect Identity Provider
- PHP for handling discovery and registration
- `grid-mapfile` for mapping authenticated user to system user
- LDAP for authenticating system user in PHP

```bash
# Whether you want to use CILogon authentication
#   OOD_AUTH_CILOGON='true'
#
# Sets the following variables =>
#   OOD_AUTH_OIDC_URI      = '/oidc'
#   OOD_AUTH_DISCOVER_ROOT = '/var/www/ood/discover'
#   OOD_AUTH_DISCOVER_URI  = '/discover'
#   OOD_AUTH_REGISTER_ROOT = '/var/www/ood/register'
#   OOD_AUTH_REGISTER_URI  = '/register'
#   OOD_USER_MAP_CMD       = '/opt/ood/ood_auth_map/bin/ood_auth_map.mapfile'
#   OOD_AUTH_TYPE          = 'openid-connect'
#   OOD_AUTH_EXTEND        = ''
#   OOD_MAP_FAIL_URI       = OOD_AUTH_REGISTER_URI
#
# You can override any of the above variables by setting them explicitly in the
# command below
#
rake OOD_AUTH_CILOGON='true'
```

You will need an appropriate Apache config that specifies the global
`mod_auth_openidc` settings you want. An example of such is given here:

```
# /path/to/httpd/conf.d/auth_openidc.conf

OIDCMetadataDir      /path/to/oidc/metadata
OIDCDiscoverURL      https://www.example.com/discover
OIDCRedirectURI      https://www.example.com/oidc
OIDCCryptoPassphrase "<Chosen Passphrase>"

# Keep sessions alive for 8 hours
OIDCSessionInactivityTimeout 28800
OIDCSessionMaxDuration 28800

# Don't pass claims to backend servers
OIDCPassClaimsAs environment

# Strip out session cookies before passing to backend
OIDCStripCookies mod_auth_openidc_session mod_auth_openidc_session_chunks mod_auth_openidc_session_0 mod_auth_openidc_session_1
```

This sets the global `mod_auth_openidc` settings used by all IdP's. Now we
setup the CILogon IdP specific settings in three separate json files:

- `/path/to/oidc/metadata/cilogon.org.provider`

    ```json
    {
      "issuer": "https://cilogon.org",
      "authorization_endpoint": "https://cilogon.org/authorize",
      "token_endpoint": "https://cilogon.org/oauth2/token",
      "userinfo_endpoint": "https://cilogon.org/oauth2/userinfo",
      "response_types_supported": [
        "code"
      ],
      "token_endpoint_auth_methods_supported": [
        "client_secret_post"
      ]
    }
    ```

- `/path/to/oidc/metadata/cilogon.org.client`

    ```json
    {
      "client_id": "<CLIENT ID>",
      "client_secret": "<CLIENT SECRET>"
    }
    ```

- `/path/to/oidc/metadata/cilogon.org.conf`

    ```json
    {
      "scope": "openid email profile org.cilogon.userinfo",
      "response_type": "code",
      "auth_request_params": "skin=default"
    }
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
