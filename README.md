# OSC Job Status for Oakley/Ruby

[![GitHub version](https://badge.fury.io/gh/OSC%2Food-activejobs.svg)](https://badge.fury.io/gh/OSC%2Food-activejobs)

Application displays the current system status of jobs running, queued, and held on the Oakley and Ruby Clusters.

## New Install

**Installation assumptions: you have an Open OnDemand installation with File Explorer and Shell apps installed and a cluster config added to /etc/ood/config/clusters.d directory.**

1. Starting in the build directory for all sys apps (i.e. `cd ~/ood_portals/ondemand/sys`), clone and check out the latest version of activejobs:

  ```sh
  scl enable git19 -- git clone https://github.com/OSC/ood-activejobs.git activejobs
  cd activejobs
  scl enable git19 -- git checkout tags/v1.2.5
  ```

2. Build the app (install dependencies and build assets)

  ```sh
  scl enable rh-ruby22 -- bin/bundle install --path vendor/bundle
  scl enable rh-ruby22 nodejs010 -- bin/rake assets:precompile RAILS_ENV=production
  scl enable rh-ruby22 -- bin/rake tmp:clear
  ```

3. Copy the built app directory to the deployment directory, and start the server.

4. Access the app through dashboard by going to /pun/sys/dashboard and then clicking "Active Jobs" from the Jobs menu

## Updating to a New Stable Version

**TODO**
