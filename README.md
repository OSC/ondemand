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
    scl enable git19 -- git checkout tags/v1.26.1
    ```

2. Install the app for a production environment:

    ```sh
    RAILS_ENV=production scl enable rh-git29 rh-nodejs6 rh-ruby24 -- bin/setup
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
    scl enable git19 -- git checkout tags/v1.26.1
    ```

2. Update the app for a production environment:

    ```sh
    RAILS_ENV=production scl enable rh-git29 rh-nodejs6 rh-ruby24 -- bin/setup
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

### Safari Warning

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

### Disk Quota Warnings

We currently support displaying warnings to users on the Dashboard if their
disk quota is nearing its limit. This requires an auto-updated (it is
recommended to update this file every **5 minutes** with a cronjob) JSON file
that lists all user quotas. The JSON schema for version `1` is given as:

```json
{
  "version": 1,
  "timestamp": 1525361263,
  "quotas": [
    {
      ...
    },
    {
      ...
    }
  ]
}
```

Where `version` defines the version of the JSON schema used, `timestamp`
defines when this file was generated, and `quotas` is a list of quota objects
(see below).

You can configure the Dashboard to use this JSON file (or files) by setting the
environment variable `OOD_QUOTA_PATH` as a colon-delimited list of all JSON
file paths.

The default threshold for displaying the warning is at 95% (`0.95`), but this
can be changed with the environment variable `OOD_QUOTA_THRESHOLD`.

An example is given as:

```shell
# /etc/ood/config/apps/dashboard/env

OOD_QUOTA_PATH="/path/to/quota1.json:/path/to/quota2.json"
OOD_QUOTA_THRESHOLD="0.80"
```

#### Individual User Quota

If the quota is defined as a `user` quota, then it applies to only disk
resources used by the user alone. This is the default type of quota object and
is given in the following format:

```json
{
  "path": "/path/to/volume1",
  "user": "user1",
  "total_block_usage": 1000,
  "block_limit": 2000,
  "total_file_usage": 5,
  "file_limit": 10
}
```

*Warning: A block must be equal to 1 KB for proper conversions.*

#### Individual Fileset Quota

If the quota is defined as a `fileset` quota, then it applies to all disk
resources used underneath a given volume. This requires the object to be
repeated for **each user** that uses disk resources under this given volume.
The format is given as:

```json
{
  "type": "fileset",
  "user": "user1",
  "path": "/path/to/volume2",
  "block_usage": 500,
  "total_block_usage": 1000,
  "block_limit": 2000,
  "file_usage": 1,
  "total_file_usage": 5,
  "file_limit": 10
}
```

Where `block_usage` and `file_usage` are the disk resource usages attributed to
the specified user only.

*Note: For each user with resources under this fileset, the above object will
be repeated with just `user`, `block_usage`, and `file_usage` changing.*

*Warning: A block must be equal to 1 KB for proper conversions.*

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
