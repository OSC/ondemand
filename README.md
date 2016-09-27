# ood_auth_map

A hodge podge grouping of scripts that can be used to map an authenticated user
name to a local user account using a variety of techniques.

## Requirements

- Ruby 1.8.7 or newer

For installation we use a `Rakefile` so `rake` is necessary only for the
installation process.

## Installation

1. Clone/pull this repo onto the local file system
    * first time installation

    ```bash
    git clone <repo> /path/to/repo
    ```
    * updating

    ```bash
    cd /path/to/repo
    git pull
    ```

2. Install a specific version in the default location

    ```bash
    cd /path/to/repo
    git checkout tags/vX.Y.Z
    sudo rake install
    ```

    this will install the specifed version `X.Y.Z` in `/opt/ood/ood_auth_map`

    Note: Running `sudo` will sanitize your current environment. For the case
    of RHEL using Software Collections it is recommended to load the
    environment inside the `sudo` process:

    ```bash
    cd /path/to/repo
    git checkout tags/vX.Y.Z
    sudo scl enable rh-ruby22 -- rake install
    ```

    Examples:

    ```bash
    # Install v1.0.0 of ood_auth_map to /opt/ood/ood_auth_map
    git checkout tags/v1.0.0
    sudo rake install

    # Install v2.0.0 of ood_auth_map to /tmp/ood_auth_map-v2.0.0
    git checkout tags/v2.0.0
    sudo rake install PREFIX=/tmp/ood_auth_map-v2.0.0
    ```

    **Warning**: This will overwrite the existing files.

## Usage

The `ood_auth_map` library comes with a variety of executable scripts that map
a URL encoded authenticated username to a local system-level username. In all
cases the only argument (besides options) the scripts accept is the
authenticated username.

If the mapping to a system-level username is successful ONLY the system-level
username string is returned to `stdout`. If the mapping is unsuccessful then
either nothing or a blank line is returned to `stdout` irrespective of what is
returned to `stderr`.

Example of successful mapping:

```bash
$ /opt/ood/ood_auth_map/bin/ood_auth_map.<type> http%3A%2F%2Fcilogon.org%2FserverA%2Fusers%2F50191
jnicklas
$
```

Example of unsuccessful mapping:

```bash
$ /opt/ood/ood_auth_map/bin/ood_auth_map.<type> http%3A%2F%2Fcilogon.org%2FserverA%2Fusers%2F52992

$
```

To get the version of the binary you are using:

```bash
$ /opt/ood/ood_auth_map/bin/ood_auth_map.<type> -v
ood_auth_map, version 1.0.0
$
```

### `ood_auth_map.mapfile`

This script parses a `grid-mapfile` defined in
http://toolkit.globus.org/toolkit/docs/2.4/gsi/grid-mapfile_v11.html for a
mapping of the authenticated username to a system-level username.

```
$ /opt/ood/ood_auth_map/bin/ood_auth_map.mapfile --help
Usage: ood_auth_map.mapfile [options] <authenticated_user>

Used to scan a grid-mapfile for a mapped authenticated user.

General options:
    -f, --file=FILE                  # File to scan for matches
                                     # Default: /etc/grid-security/grid-mapfile

Common options:
    -h, --help                       # Show this help message
    -v, --version                    # Show version

Examples:
    To scan the default grid-mapfile using a url-encoded authenticated
    username:

        ood_auth_map.mapfile http%3A%2F%2Fcilogon.org%2FserverA%2Fusers%2F58606%40cilogon.org

    this will return an empty string if no matches are found.

    To scan a custom grid-mapfile using authenticated username:

        ood_auth_map.mapfile --file=/path/to/mapfile http://cilogon.org/serverA/users/53756@cilogon.org

    this file must follow the rules for grid-mapfile's listed at
    http://toolkit.globus.org/toolkit/docs/2.4/gsi/grid-mapfile_v11.html
```

### `ood_auth_map.regex`

This script parses the authenticated username using a defined regular
expression pattern to capture the system-level username. The default regular
expression if none is defined just echos back the authenticated username. If
nothing matches the defined regular expression pattern, a blank string is
returned indicated no match was found.

```
$ /opt/ood/ood_auth_map/bin/ood_auth_map.regex --help
Usage: ood_auth_map.regex [options] <authenticated_user>

Used to parse for a mapped authenticated user from a string using a regular expression.

General options:
    -r, --regex=REGEX                # Regular expression used to capture the system-level username
                                     # Default: ^(.+)$

Common options:
    -h, --help                       # Show this help message
    -v, --version                    # Show version

Examples:
    If the authenticated username completely matches the system-level
    username use the default regular expression:

        ood_auth_map.regex bob

    this will return `bob`.

    For more complicated strings, a regular expression needs to be
    supplied as an option:

        ood_auth_map.regex --regex='^(\w+)@osc.edu$' bob@osc.edu

    where the first captured match is returned as the system-level username.

    If no match is found in the string, then a blank line is returned:

        ood_auth_map.regex --regex='^(\w+)@osc.edu$' bob@mit.edu

    this will return a blank line, meaning no match was found.
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/ood_auth_map/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
