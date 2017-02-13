# OSC Job Status for Oakley/Ruby

[![GitHub version](https://badge.fury.io/gh/OSC%2Food-activejobs.svg)](https://badge.fury.io/gh/OSC%2Food-activejobs)

Application displays the current system status of jobs running, queued, and held on the Oakley and Ruby Clusters.

## New Install

**Installation assumptions: you have an Open OnDemand installation with File Explorer and Shell apps installed and a cluster config added to /etc/ood/config/clusters.d directory.**

1. Starting in the build directory for all sys apps (i.e. `cd ~/ood_portals/ondemand/sys`), clone and check out the latest version of activejobs:

  ```sh
  scl enable git19 -- git clone https://github.com/OSC/ood-activejobs.git activejobs
  cd activejobs
  scl enable git19 -- git checkout tags/v1.3.0
  ```

2. Build the app (install dependencies and build assets)

  ```sh
  scl enable rh-ruby22 -- bin/bundle install --path vendor/bundle
  scl enable rh-ruby22 nodejs010 -- bin/rake assets:precompile RAILS_ENV=production
  scl enable rh-ruby22 -- bin/rake tmp:clear
  ```

3. Copy the built app directory to the deployment directory, and start the server. i.e.:

  ```sh
  mkdir -p /var/www/ood/apps/sys/activejobs
  rsync -rlptvu . /var/www/ood/apps/sys/activejobs
  ```

4. Access the app through dashboard by going to /pun/sys/dashboard and then clicking "Active Jobs" from the Jobs menu

## Updating to a New Stable Version

When updating a deployed version of the Open OnDemand activejobs app.

1. Fetch and checkout new version of code:

  ```sh
  cd dashboard # cd to build directory
  scl enable git19 -- git fetch
  scl enable git19 -- git checkout tags/v1.2.5 # check out latest tag
  ```

2. Install gem dependencies and rebuild assets

  ```sh
  scl enable rh-ruby22 -- bin/bundle install --path vendor/bundle
  scl enable rh-ruby22 -- bin/rake tmp:clear
  scl enable rh-ruby22 -- bin/rake assets:clobber RAILS_ENV=production
  scl enable rh-ruby22 nodejs010 -- bin/rake assets:precompile RAILS_ENV=production
  ```

3. Restart app

  ```sh
  touch tmp/restart.txt
  ```

4. Copy the built app directory to the deployment directory. There is no need to restart the server. Because we touched `tmp/restart.txt` in the app, the next time a user accesses an app Passenger will reload their app.

## Configuration

This application depends on a valid `ood_cluster` configuration. Please see the [ood_cluster](https://github.com/OSC/ood_cluster/blob/master/README.md) README for further details.

This application relies upon the `ood_appkit` dependency for certain branding defaults. You may override these defaults by creating an `.env.local` file in the root folder of this app and adding the variables there. See the documentation at [ood_appkit](https://github.com/OSC/ood_appkit) for further details.
