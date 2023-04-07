# Open OnDemand Dashboard

This app is a Rails app for Open OnDemand that serves as a gateway to launching
other Open OnDemand apps. Like all Open OnDemand apps, it's meant to runs as a non-root
user.

This is a guide to developing the dashboard.

This documentation assumes you have [development enabled](https://osc.github.io/ood-documentation/latest/app-development/enabling-development-mode.html)
for yourself.  Containers built in [the development documentation](../../DEVELOPMENT.md)
have development enabled automatically.

## Getting started

First, you'll need to clone this repo and make a symlink.

```text
mkdir -p ~/ondemand/dev
git clone https://github.com/OSC/ondemand.git ~/ondemand/src
cd ~/ondemand/dev
ln -s ../src/apps/dashboard
```

Open OnDemand sees all of the apps in `~/ondemand/dev` and the
dashboard is just like any other!

## Building

Prerequisites to building are ruby 3.0 and nodejs 14.  You'll also need gcc
and g++ to build gems and node packages.  Getting these available on your systems
is left to the reader.

They are available on the webnode based off of RPM/deb package dependencies.
However, you may choose to have a different development runtime, and that's fine.
OSC maintainers use `modules` on compute nodes instead of developing on the webnodes
themselves.

It should be noted here that any Ruby module installation needs configured with
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

## Customizing

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
