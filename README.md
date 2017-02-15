# ood-portal-generator

![GitHub Release](https://img.shields.io/github/release/osc/ood-portal-generator.svg)
![GitHub License](https://img.shields.io/github/license/osc/ood-portal-generator.svg)

Generates an Open OnDemand portal config for an Apache server.

## Requirements

### Generate OOD Portal config

- `ruby` 1.9+

### Run OOD Portal config

- Apache `httpd` 2.4.12+ (and the following modules)

  | **modules required**                                   |
  | --------------------------------------------------     |
  | [mod_ood_proxy](https://github.com/OSC/mod_ood_proxy/) |
  | mod_lua                                                |
  | mod_env                                                |
  | mod_headers                                            |
  | mod_proxy (mod_proxy_connect + mod_proxy_wstunnel)     |
  | mod_auth_* (e.g., mod_authnz_ldap)                     |

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

    To modify any configuration options from the default, copy the default
    config file and modify the respective options followed by running `rake`
    again:

    ```bash
    # Copy over the default config
    cp config.default.yml config.yml

    # Modify the respective options
    vim config.yml

    # When you are done, then re-compile the config
    rake

    # If using Software Collections, set Ruby environment
    # scl enable rh-ruby22 -- rake
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

The default options are all outlined in the included `config.default.yml`:

```yaml
# ./config.default.yml
---
#
# Portal configuration
#

# The address and port to listen for connections on
# Example:
#     listen_addr_port: 443
# Default: null (don't add any more listen directives)
listen_addr_port: null

# The server name used for name-based Virtual Host
# Example:
#     servername: 'www.example.com'
# Default: null (don't use name-based Virtual Host)
servername: null

# The port specification for the Virtual Host
# Example:
#     port: 8080
#Default: null (use default port 80 or 443 if SSL enabled)
port: null

# List of SSL Apache directives
# Example:
#     ssl:
#       - 'SSLCertificateFile "/etc/pki/tls/certs/www.example.com.crt"'
#       - 'SSLCertificateKeyFile "/etc/pki/tls/private/www.example.com.key"'
# Default: null (no SSL support)
ssl: null

# Root directory of log files (can be relative ServerRoot)
# Example:
#     logroot: '/path/to/my/logs'
# Default: 'logs' (this is relative to ServerRoot)
logroot: 'logs'

# Root directory of the Lua handler code
# Example:
#     lua_root: '/path/to/lua/handlers'
# Default : '/opt/ood/mod_ood_proxy/lib' (default install directory of mod_ood_proxy)
lua_root: '/opt/ood/mod_ood_proxy/lib'

# Verbosity of the Lua module logging
# (see https://httpd.apache.org/docs/2.4/mod/core.html#loglevel)
# Example:
#     lua_log_level: 'info'
# Default: null (use default log level)
lua_log_level: null

# System command used to map authenticated-user to system-user
# Example:
#     user_map_cmd: '/opt/ood/ood_auth_map/bin/ood_auth_map.regex --regex=''^(\w+)@example.com$'''
# Default: '/opt/ood/ood_auth_map/bin/ood_auth_map.regex' (this echo's back auth-user)
user_map_cmd: '/opt/ood/ood_auth_map/bin/ood_auth_map.regex'

# Redirect user to the following URI if fail to map there authenticated-user to
# a system-user
# Example:
#     map_fail_uri: '/register'
# Default: null (don't redirect, just display error message)
map_fail_uri: null

# System command used to run the `nginx_stage` script with sudo privileges
# Example:
#     pun_stage_cmd: 'sudo /path/to/nginx_stage'
# Default: 'sudo /opt/ood/nginx_stage/sbin/nginx_stage' (don't forget sudo)
pun_stage_cmd: 'sudo /opt/ood/nginx_stage/sbin/nginx_stage'

# List of Apache authentication directives
# NB: Be sure the appropriate Apache module is installed for this
# Default: (see below, uses basic auth with an htpasswd file)
auth:
  - 'AuthType Basic'
  - 'AuthName "private"'
  - 'AuthUserFile "/opt/rh/httpd24/root/etc/httpd/.htpasswd"'
  - 'RequestHeader unset Authorization'
  - 'Require valid-user'

# Redirect user to the following URI when accessing root URI
# Example:
#     root_uri: '/my_uri'
#     # https://www.example.com/ => https://www.example.com/my_uri
# Default: '/pun/sys/dashboard' (default location of the OOD Dashboard app)
root_uri: '/pun/sys/dashboard'

# Track server-side analytics with a Google Analytics account and property
# (see https://github.com/OSC/mod_ood_proxy/blob/master/lib/analytics.lua for
# information on how to setup the GA property)
# Example:
#     analytics:
#       url: 'http://www.google-analytics.com/collect'
#       id: 'UA-79331310-4'
# Default: null (do not track)
analytics: null

#
# Publicly available assets
#

# Public sub-uri (available to public with no authentication)
# Example:
#     public_uri: '/assets'
# Default: '/public'
public_uri: '/public'

# Root directory that serves the public sub-uri (be careful, everything under
# here is open to the public)
# Example:
#     public_root: '/path/to/public/assets'
# Default: '/var/www/ood/public'
public_root: '/var/www/ood/public'

#
# Reverse proxy to backend nodes
#

# Regular expression used for whitelisting allowed hostnames of nodes
# Example:
#     host_regex: '[\w.-]+\.example\.com'
# Default: '[^/]+' (allow reverse proxying to all hosts, this allows external
# hosts as well)
host_regex: '[^/]+'

# Sub-uri used to reverse proxy to backend web server running on node that
# knows the full URI path
# Example:
#     node_uri: '/node'
# Default: null (disable this feature)
node_uri: null

# Sub-uri used to reverse proxy to backend web server running on node that
# ONLY uses *relative* URI paths
# Example:
#     rnode_uri: '/rnode'
# Default: null (disable this feature)
rnode_uri: null

#
# Per-user NGINX Passenger apps
#

# Sub-uri used to control PUN processes
# Example:
#     nginx_uri: '/my_pun_controller'
# Default: '/nginx'
nginx_uri: '/nginx'

# Sub-uri used to access the PUN processes
# Example:
#     pun_uri: '/my_pun_apps'
# Default: '/pun'
pun_uri: '/pun'

# Root directory that contains the PUN Unix sockets that the proxy uses to
# connect to
# Example:
#     pun_socket_root: '/path/to/pun/sockets'
# Default: '/var/run/nginx' (default location set in nginx_stage)
pun_socket_root: '/var/run/nginx'

# Number of times the proxy attempts to connect to the PUN Unix socket before
# giving up and displaying an error to the user
# Example:
#     pun_max_retries: 25
# Default: 5 (only try 5 times)
pun_max_retries: 5

#
# Support for OpenID Connect
#

# Sub-uri used by mod_auth_openidc for authentication
# Example:
#     oidc_uri: '/oidc'
# Default: null (disable OpenID Connect support)
oidc_uri: null

# Sub-uri user is redirected to if they are not authenticated. This is used to
# *discover* what ID provider the user will login through.
# Example:
#     oidc_discover_uri: '/discover'
# Default: null (disable support for discovering OpenID Connect IdP)
oidc_discover_uri: null

# Root directory on the filesystem that serves the HTML code used to display
# the discovery page
# Example:
#     oidc_discover_root: '/var/www/ood/discover'
# Default: null (disable support for discovering OpenID Connect IdP)
oidc_discover_root: null

#
# Support for registering unmapped users
#
# (Not necessary if using regular expressions for mapping users)
#

# Sub-uri user is redirected to if unable to map authenticated-user to
# system-user
# Example:
#     register_uri: '/register'
# Default: null (display error to user if mapping fails)
register_uri: null

# Root directory on the filesystem that serves the HTML code used to register
# an unmapped user
# Example:
#     register_root: '/var/www/ood/register'
# Default: null (display error to user if mapping fails)
register_root: null
```

## OOD Analytics

The analytics are generated/submitted during the logging stage after the
request-response process. Currently they only support submitting data to Google
Analtyics. For further information on how to set up a Google Analytics property
please see https://github.com/OSC/mod_ood_proxy/blob/master/lib/analytics.lua

To further support this project we recommend submitting your analytics to OSC's
Google Analytics account, but this is not a requirement:

```yaml
# ./config.yml
---

analytics:
  url: 'http://www.google-analytics.com/collect'
  id: 'UA-79331310-4'
```

## OOD Authentication

Authentication is not just a requirement for keeping your resources secure, but
also for proxying the authenticated user to their corresponding per-user NGINX
instance.

### Default Authentication Setup

This uses Apache Basic authentication as the default authentication mechanism,
utilizing an encrypted password file
(https://httpd.apache.org/docs/2.4/howto/auth.html#gettingitworking):

This default configuration is given as:

```yaml
# ./config.yml
---

# Use basic authentication with password file
auth:
  - 'AuthType Basic'
  - 'AuthName "private"'
  - 'AuthUserFile "/opt/rh/httpd24/root/etc/httpd/.htpasswd"'
  - 'RequestHeader unset Authorization'
  - 'Require valid-user'
```

Where `/opt/rh/httpd/root/etc/httpd/.htpasswd` is the location of the encrypted
password file. This will need to be generated beforehand for your corresponding
users. The user passwords do not need to correlate to their system passwords as
the user mapping will map the authenticated-user to the system-user.

The option `RequestHeader unset Authorization` is necessary to strip the user's
web password from the request headers sent to the backend web services. Please
do not remove this line unless you know what you are doing.

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

If you continue to use Basic authentication, we recommend using the LDAP module
(`mod_authnz_ldap`) with a configuration along the lines of:

```yaml
# ./config.yml
---

# Use LDAP basic authentication
auth:
  - 'AuthType Basic'
  - 'AuthName "private"'
  - 'AuthBasicProvider ldap'
  - 'AuthLDAPURL "ldaps://ldap1.example.com:636 ldap2.example.com:636/ou=People,ou=hpc,o=example?uid" SSL'
  - 'AuthLDAPGroupAttribute memberUid'
  - 'AuthLDAPGroupAttributeIsDN off'
  - 'RequestHeader unset Authorization'
  - 'Require valid-user'
```

### Shibboleth Authentication Setup

*Work in progress*

**Assumes you have a Shibboleth IdP already deployed and setup.**

Requires the Shibboleth module (`mod_shib_*`) with a configuration along the
lines of:

```yaml
# ./config.yml
---

# Capture system-username from authenticated-username
user_map_cmd: '/opt/ood/ood_auth_map/bin/ood_auth_map.regex --regex=''^(\w+)@example.com$'''

# Use Shibboleth authentication
auth:
  - 'AuthType shibboleth'
  - 'ShibRequestSetting requireSession 1'
  - 'RequestHeader edit* Cookie "(^_shibsession_[^;]*(;\s*)?|;\s*_shibsession_[^;]*)" ""'
  - 'RequestHeader unset Cookie "expr=-z %{req:Cookie}"'
  - 'Require valid-user'
```

The `RequestHeader` settings are used to strip private user information from
being sent to the backend web services. Please do not remove these lines unless
you know what you are doing.

You will then need an appropriate Apache config that specifies the global
`mod_shib_*` settings you want. An example of such is given here:

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

### CILogon Authentication Setup (very OSC-specific)

**This is currently very OSC-specific and may not work at all at your center**

Requirements:

- [mod_auth_openidc](https://github.com/pingidentity/mod_auth_openidc) v2.0.0+ / CILogon client information
- [ood_auth_discovery](ihttps://github.com/OSC/ood_auth_discovery/) (PHP scripts)
- [ood_auth_registration](https://github.com/OSC/ood_auth_registration/) (PHP scripts)
- [ood_auth_mapdn](https://github.com/OSC/ood_auth_mapdn/) (Python + MySQL scripts)

This authentication mechanism takes advantage of:

- `mod_auth_openidc` for the authentication handler in Apache
- CILogon for the OpenID Connect Identity Provider
- PHP for handling discovery and registration
- `grid-mapfile` for mapping authenticated user to system user
- LDAP for authenticating system user in PHP

An example configuration file may look like:

```yaml
# ./config.yml
---

# Use a grid-mapfile for mapping authenticated-user to system-user
user_map_cmd: '/opt/ood/ood_auth_map/bin/ood_auth_map.mapfile'

# Use OpenID Connect for authentication
auth:
  - 'AuthType openid-connect'
  - 'Require valid-user'

# OpenID Connect options
oidc_uri: '/oidc'
oidc_discover_uri: '/discover'
oidc_discover_root: '/var/www/ood/discover'

# Allow user to register their authenticated-username to a local
# system-username
register_uri: '/register'
register_root: '/var/www/ood/register'

# If a user can't be mapped to a system-user, then redirect them to the
# registration page
map_fail_uri: '/register'
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

## Contributing

1. Fork it ( https://github.com/OSC/ood-portal-generator/fork  )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
