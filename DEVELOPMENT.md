# Developing Open OnDemand

This a a guide to developing Open OnDemand.

You can develop Open OnDemand through a [fullstack container](#fullstack-container)
or through an existing Open OnDemand installation to [develop the dashboard](#developing-the-dashboard).

[Developing the dashboard](#developing-the-dashboard) on an existing Open OnDemand installation
is the preferred method as you'll have direct access to the HPC cluster you're submitting jobs to.

1. [Developing the dashboard](#developing-the-dashboard)
    1. [Getting started developing the dashboard](#getting-started-developing-the-dashboard)
    2. [Building the dashboard](#building-the-dashboard)
    3. [Re-compiling Javascript](#re-compiling-javascript)
    4. [Developing ood_core](#developing-ood_core)
    5. [Customizing the dashboard](#customizing-the-dashboard)
2. [Fullstack container](#fullstack-container)
    1. [Getting started with the fullstack container](#getting-started-with-the-fullstack-container)
    2. [Login to the container](#login-to-the-container)
    3. [Configuring the container](#configuring-the-container)
    4. [Rebuilding the image](#rebuilding-the-image)
    5. [Additional Capabilities](#additional-capabilities)
    6. [Additional Mounts](#additional-mounts)


## Developing the Dashboard

The ``dashboard`` application is a Ruby on Rails application that serves as a
gateway to launching other Open OnDemand applications. Like all Open OnDemand
applications, it's meant to runs as a non-root user.

This documentation assumes you have [development enabled](https://osc.github.io/ood-documentation/latest/app-development/enabling-development-mode.html) for yourself on an existing Open OnDemand installation.

### Getting started developing the dashboard

First, you'll need to clone this repository and make a symlink.

```text
mkdir -p ~/ondemand/dev
git clone git@github.com:OSC/ondemand.git ~/ondemand/src
cd ~/ondemand/dev
ln -s ../src/apps/dashboard
```

Open OnDemand sees all of the apps in `~/ondemand/dev` and the
dashboard is just like any other!


### Building the dashboard

Prerequisites to building are ruby 3.0 and nodejs 14.  You'll also need gcc
and g++ to build gems and node packages.  Getting these available on your systems
is left to the reader.

They are available on the webnode based off of RPM/deb package dependencies.
However, you may choose to have a different development runtime, and that's fine.
OSC maintainers use `modules` on compute nodes instead of developing on the webnodes
themselves.

It should be noted here that any Ruby module installation needs to be configured with
`--enable-shared` flag to be compatible with the Ruby running on the webnode.

Now run `bin/setup` from within this directory to fetch all the dependencies
and compile.

```
# advanced users may not need to configure bundle. Container users must do this.
bin/bundle config path --local vendor/bundle

bin/setup
```

Now you should be able to navigate to `/pun/dev/dashboard` and see the app
in the developer views.

### Re-compiling Javascript

Since we migrated to `esbuild` assets are no longer built automatically. If you are
editing any css, javascript or images during development, you may find the
helper script `bin/recompile_js` useful to run the asset pipeline for your changes
to become available to the app.

### Developing ood_core

If you're making updates to the `ood_core` gem (or indeed any other gem that you have
development access to) hack the Gemfile to point to the source location and issue 
`bin/bundle update`.

```
gem 'ood_core', :path=> '/full/path/to/checked/out/ood_core'
```

Now your development dashboard will look at this location for this gem. You may
have to restart the server from time to time to pick up the new source code as
Rails is going to cache that code.

Be sure not to commit these changes! They won't work in the CI as that location
is likely to be specific to your HOME directory on any given machine.

### Customizing the dashboard

Now you can refer to the [documentation on customizing](https://osc.github.io/ood-documentation/latest/customization.html)
and make those changes to a `.env.local` file in the same directory as
this README.md.

Refer to [the configuration class](config/configuration_singleton.rb) to see every option
available.

Here's the user Annie Oakley's `.env.local` file to get you started.

```
# ~/ondemand/dev/dashboard/.env.local

OOD_BRAND_BG_COLOR="#c1a226" #gold
#OOD_LOAD_EXTERNAL_CONFIG=1
#OOD_LOAD_EXTERNAL_BC_CONFIG=1
OOD_APP_SHARING=true

MOTD_PATH="/etc/motd"
MOTD_FORMAT="osc"
SHOW_ALL_APPS_LINK=1

OOD_CLUSTERS="/home/annie.oakley/ondemand/misc/clusters.d"
OOD_CONFIG_D_DIRECTORY="/home/annie.oakley/ondemand/misc/config/ondemand.d"

OOD_BALANCE_PATH="/home/annie.oakley/ondemand/misc/config/balances.json"
OOD_BALANCE_THRESHOLD=50
OOD_QUOTA_PATH="/home/annie.oakley/ondemand/misc/config/quotas/my_quota.json"
OOD_QUOTA_THRESHOLD=0.1
```

`.env.local` files have this limitation: They'll only set environment variables that
aren't already set. As an example, you can't override `HOME` here, because it's
likely already set.

In this case, you'd need an `.env.overload` file. Overload files have precedence over
all other env files and indeed the environment itself.  This will override _any_
environment variable whether it's set or not.

This is required to override environment variables that you yourself are not in control
of. An example of this is `OOD_EDITOR_URL` that is set in the `ood_appkit` gem that points
to the system installed editor. While developing this app, you may want to point to the
development instance of the editor instead. A `.env.local` setting will not override this
value but a `.env.overload` will.

Here are the most common environment variables you may need to override.

```
OOD_EDITOR_URL='/pun/dev/dashboard/files'
OOD_FILES_URL='/pun/dev/dashboard/files'
```


## Fullstack container

### Getting started with the fullstack container

This container will create a duplicate user
with the same group and user id.  Starting the container will prompt
you to set a password.  This is only credentials for web access to the
container.

Pull down this source code and start the container.  We support podman
by setting the environment variable `CONTAINER_RT=podman`.

```text
mkdir -p ~/ondemand
git clone https://github.com/OSC/ondemand.git ~/ondemand/src
cd ~/ondemand/src
bundle config --local path vendor/bundle
bundle install
rake dev:start
```

See `rake --tasks` for all the `dev:` related tasks.

```
rake dev:exec                               # Bash exec into the development container
rake dev:bash                               # alias for dev:exec
rake dev:restart                            # Restart development container
rake dev:start                              # Start development container
rake dev:stop                               # Stop development container
```

### Login to the container

Here's the important bit about user mapping with containers. Let's use the
example of `jessie` with `id` below. In creating the development container,
we added a user with the same.  The password is for `dex` the IDP, and the
web only.

```
uid=1000(jessie) gid=1000(jessie) groups=1000(jessie)
```

Now you'll be able to access `http://localhost:8080/` where it'll redirect
you to `dex` the OpenID Connect provider within the container. Use the email
`<your username>@localhost`.


### Configuring the container

In starting the container, you may see the mount
`~/.config/ondemand/container/config:/etc/ood/config`.  This mount allows us to
completely configure this Open-OnDemand container.

Create and edit files in the host's home directory and to mount in
new configurations.

Edit or remove `~/.config/ondemand/container/config/ood_portal.yml` to change
your container's password.

### Rebuilding the image

All the development tasks will use the `ood-dev:latest` image.  If
you want to rebuild to a newer version use the rebuild task.

```text
rake dev:rebuild
```

### Additional Capabilities

While starting this container, this library will respond to some environment
variables you may want and/or need.

For example if you need additional Linux capabilities you can use `OOD_CTR_CAPABILITIES`
with a comma separated list of the capabilities you want.

If `privileged` is in this list, no capabilities are used and the container is ran with
the `--privileged` flag.

```shell
OOD_CTR_CAPABILITIES=net_raw,net_admin
```

### Additional Mounts

You can mount the current directory to override what exists in the container
by setting _anything_ in the `OOD_MNT_` environment variables.

* `OOD_MNT_PORTAL` mounts <project_root>/ood-portal-generator to /opt/ood/ood-portal-generator
* `OOD_MNT_NGINX` mounts <project_root>/nginx_stage to /opt/ood/nginx_stage
* `OOD_MNT_PROXY` mounts <project_root>/ood_proxy to /opt/ood/ood_proxy
