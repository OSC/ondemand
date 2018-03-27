# OOD Dashboard

[![Build Status](https://travis-ci.org/OSC/ood-dashboard.svg?branch=master)](https://travis-ci.org/OSC/ood-dashboard)
[![GitHub version](https://badge.fury.io/gh/OSC%2Food-dashboard.svg)](https://badge.fury.io/gh/OSC%2Food-dashboard)
[![GitHub License](https://img.shields.io/badge/license-MIT-green.svg)](https://opensource.org/licenses/MIT)

This app is a Rails app for Open OnDemand that serves as a gateway to launching
other Open OnDemand apps. It is meant to be run as the user (and on behalf of
the user) using the app. Thus, at an HPC center if I log into OnDemand using
the `efranz` account, this app should run as `efranz`. This Rails app doesn't
use a database.

## New Install


1. Start in the **build directory** for all sys apps, clone and check out the
   latest version of the dashboard app (make sure the app directory's name is
   `dashboard`):

   ```sh
   scl enable git19 -- git clone https://github.com/OSC/ood-dashboard.git dashboard
   cd dashboard
   scl enable git19 -- git checkout tags/v1.24.0
   ```

2. Install the app for a production environment:

   ```sh
   RAILS_ENV=production scl enable git19 rh-ruby22 nodejs010 -- bin/setup
   ```

   this will setup a default Open OnDemand install.

3. Copy the built app directory to the deployment directory, and start the
   server. i.e.:

   ```sh
   sudo mkdir -p /var/www/ood/apps/sys/dashboard
   sudo cp -r . /var/www/ood/apps/sys/dashboard
   ```

## Updating to a New Stable Version

1. Navigate to the app's build directory and check out the latest version:

   ```sh
   cd dashboard # cd to build directory
   scl enable git19 -- git fetch
   scl enable git19 -- git checkout tags/v1.24.0
   ```

2. Update the app for a production environment:

   ```sh
   RAILS_ENV=production scl enable git19 rh-ruby22 nodejs010 -- bin/setup
   ```

3. Copy the built app directory to the deployment directory:

   ```sh
   sudo rsync -rlptv --delete . /var/www/ood/apps/sys/dashboard
   ```

## iHPC App Development

See the OnDemand documentation site: https://osc.github.io/ood-documentation/master/app-development.html

## Configuration

See the wiki page https://github.com/OSC/ood-dashboard/wiki/Configuration-and-Branding

### Message Of The Day

See the wiki page https://github.com/OSC/ood-dashboard/wiki/Message-of-the-Day

### Site-wide announcement

See the wiki page https://github.com/OSC/ood-dashboard/wiki/Site-Wide-Announcement

## Safari Warning

We currently display an alert message at the top of the Dashboard mentioning
that we don't currently support the Safari browser. This is because of an issue
in Safari where it fails to connect to websockets if the Apache proxy uses
Basic Auth for user authentication (on by default for new OOD installations).

If you ever change the authentication mechanism to a cookie-based mechanism
(e.g., Shibboleth or OpenID Connect), then it is recommended you disable this
alert message in the dashboard.

You can do this by modifying the `.env.local` file as such:

```sh
# .env.local

# ... all of your other settings ...

# Set this to disable Safari + Basic Auth warning
DISABLE_SAFARI_BASIC_AUTH_WARNING=1
```

## API

### iHPC CLI

You can launch iHPC sessions using a rake task. See the wiki page
https://github.com/OSC/ood-dashboard/wiki/iHPC-CLI

## Development

### Updating noVNC

To update noVNC you need to first download and unzip the latest stable Node.js.
You can find the latest downloads here:

https://nodejs.org/en/download/

For our demonstration purposes I will use Node.js v6.11.1:

```sh
# Go to my home directory
cd ${HOME}

# Get latest stable node.js
wget https://nodejs.org/dist/v6.11.1/node-v6.11.1-linux-x64.tar.xz

# Unzip it
tar xf node-v6.11.1-linux-x64.tar.xz
```

Next we download and build noVNC:

```sh
# Go to my home directory
cd ${HOME}

# Download the commit of noVNC we are interested in
wget https://github.com/novnc/noVNC/archive/edb7879927c18dd2aaf3b86c99df69ba4fbb0eab.zip

# Unzip it
unzip edb7879927c18dd2aaf3b86c99df69ba4fbb0eab.zip

# Go into the noVNC directory
cd noVNC-edb7879927c18dd2aaf3b86c99df69ba4fbb0eab/

# Install the dependency packages
PATH=${HOME}/node-v6.11.1-linux-x64/bin:$PATH npm install

# Build the noVNC libraries
PATH=${HOME}/node-v6.11.1-linux-x64/bin:$PATH utils/use_require.js --as commonjs --with-app
```

Now we copy the build to our Dashboard code under the `public/` root with an
appropriately named directory (typically a shortened-form of the SHA commit):

```sh
cp -r build ${HOME}/ondemand/dev/ood-dashboard/public/noVNC-edb7879
```

Finally we need to update the Dashboard code to use this new version of noVNC.
We edit this file under the Dashboard code:

```
app/helpers/batch_connect/sessions_helper.rb
```

And modify `BatchConnect::SessionsHelper#novnc_link` with the new version.

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/OSC/ood-dashboard.

## License

The gem is available as open source under the terms of the [MIT
License](http://opensource.org/licenses/MIT).
