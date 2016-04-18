# osc-user-map

Ohio Supercomputer Center tool for mapping an authenticated username to a
system-level username.

## Requirements

- Ruby 1.8.7 or newer
- A plain text grid-mapfile located at `/etc/grid-security/grid-mapfile`

For installation we use a `Rakefile` so `rake` is necessary only for the
installation process.

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

2. Install a specific version in the default location

    ```
    cd /path/to/repo
    git checkout tags/vX.Y.Z
    sudo rake install
    ```

    this will install the specifed version `X.Y.Z` in `/opt/ood/osc-user-map`

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
    # Install v1.0.0 of osc-user-map to /opt/ood/osc-user-map
    git checkout tags/v1.0.0
    sudo rake install

    # Install v2.0.0 of osc-user-map to /tmp/osc-user-map-v2.0.0
    git checkout tags/v2.0.0
    sudo rake install PREFIX=/tmp/osc-user-map-v2.0.0
    ```

    **Warning**: This will overwrite the existing files.

## Usage

The command `osc-user-map` only accepts a single argument. The first argument
supplied to the command is the URL encoded authenticated username. If the
mapping to a system-level username is successful ONLY the system-level username
string is returned to `stdout`. If the mapping is unsuccessful then either
nothing or a blank line is returned to `stdout` irrespective of what is
returned to `stderr`.

Example of successful mapping:

```bash
$ /opt/ood/osc-user-map/bin/osc-user-map http%3A%2F%2Fcilogon.org%2FserverA%2Fusers%2F50191
jnicklas
$
```

Example of unsuccessful mapping:

```bash
$ /opt/ood/osc-user-map/bin/osc-user-map http%3A%2F%2Fcilogon.org%2FserverA%2Fusers%2F52992

$
```

To get the version of the binary you are using:

```bash
$ /opt/ood/osc-user-map/bin/osc-user-map -v
osc-user-map v1.0.0
$
```

## grid-mapfile

The `grid-mapfile` must conform to the format specified at

http://toolkit.globus.org/toolkit/docs/2.4/gsi/grid-mapfile_v11.html

## Contributing

1. Fork it ( https://github.com/[my-github-username]/osc-user-map/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
