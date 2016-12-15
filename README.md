# OOD Dashboard

[![GitHub version](https://badge.fury.io/gh/OSC%2Food-dashboard.svg)](https://badge.fury.io/gh/OSC%2Food-dashboard)

This app is a Rails app for Open OnDemand that serves as a gateway to launching other Open OnDemand apps. It is meant to be run as the user (and on behalf of the user) using the app. Thus, at an HPC center if I log into OnDemand using the `efranz` account, this app should run as `efranz`. This Rails app doesn't use a database.

## New Install


1. Starting in the build directory for all sys apps (i.e. `cd ~/ood_portals/ondemand/sys`), clone and check out the latest version of the dashboard (make sure the app directory's name is "dashboard"):

  ```sh
  git clone https://github.com/OSC/ood-dashboard.git dashboard
  cd dashboard
  git checkout tags/v1.6.1
  ```

2. Build the app (install dependencies and build assets)

  ```sh
  scl enable git19 nodejs010 rh-ruby22 -- bin/bundle install --path vendor/bundle
  scl enable git19 nodejs010 rh-ruby22 -- bin/rake assets:precompile RAILS_ENV=production
  scl enable git19 rh-ruby22 nodejs010 -- bin/rake tmp:clear
  ```

3. Copy the built app directory to the deployment directory, and start the server.

4. Access the dashboard by going to /pun/sys/dashboard


## Updating to a New Stable Version

When updating a deployed version of the Open OnDemand dashboard.


1. Fetch and checkout new version of code:

  ```sh
  cd dashboard # cd to build directory
  scl enable git19 -- git fetch
  scl enable git19 -- git checkout tags/v1.6.1 # check out latest tag
  ```

2. Install gem dependencies and rebuild assets

  ```sh
  scl enable git19 nodejs010 rh-ruby22 -- bin/bundle install --path vendor/bundle
  scl enable git19 nodejs010 rh-ruby22 -- bin/rake tmp:clear
  scl enable git19 nodejs010 rh-ruby22 -- bin/rake assets:clobber RAILS_ENV=production
  scl enable git19 nodejs010 rh-ruby22 -- bin/rake assets:precompile RAILS_ENV=production
  ```

3. Restart app

  ```sh
  touch tmp/restart.txt
  ```

4. Copy the built app directory to the deployment directory. There is no need to restart the server. Because we touched `tmp/restart.txt` in the app, the next time a user accesses an app Passenger will reload their app.

## Configuration

See the wiki page https://github.com/OSC/ood-dashboard/wiki/Configuration-and-Branding

### Message Of The Day

See the wiki page https://github.com/OSC/ood-dashboard/wiki/Message-of-the-Day

### App Sharing

**This is a feature currently in development. The documentation below is for developers working on this feature.**

See the wiki page https://github.com/OSC/ood-dashboard/wiki/App-Sharing
