# ood-portal-generator

Generates an Open OnDemand portal config for an Apache server.

## Requirements

### Generate OOD Portal config

- GNU Make
- gettext (in particular `envsubst`)

### Run OOD Portal config

- Apache httpd 2.4
- mod_ood_proxy (and its requirements)
- mod_env
- mod_lua
- mod_auth_openidc

## Installation

1.  Clone/pull this repo onto the local file system
    - first time installation

        ```
        git clone <repo> /path/to/repo
        ```
    - updating

        ```
        cd /path/to/repo
        git pull
        ```

2.  If you haven't already done before, copy the example Makefile

    ```
    cp Makefile.example Makefile
    ```

3.  Modify the variables in `Makefile` to match the setup of your system.

4.  Install the Apache config that defines the OOD Portal

    ```
    make
    sudo make install
    ```

5.  Restart your apache server.

## Version

To list the current version being used when building an OOD Portal config file,
use:

```
make version
```

For individual configs, the version is listed in the header of the file.
