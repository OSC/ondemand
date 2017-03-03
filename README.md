# OOD My Jobs

[![GitHub version](https://badge.fury.io/gh/OSC%2Food-myjobs.svg)](https://badge.fury.io/gh/OSC%2Food-myjobs)

OOD Rails app for Open OnDemand for creating and managing batch jobs from template directories.

## New Install

**Installation assumptions: you have an Open OnDemand installation with File Explorer and Shell apps installed and a cluster config added to /etc/ood/config/clusters.d directory.**

1. Starting in the build directory for all sys apps (i.e. `cd ~/ood_portals/ondemand/sys`), clone and check out the latest version of myjobs (make sure the app directory's name is "myjobs"):

  ```sh
  scl enable git19 -- git clone https://github.com/OSC/ood-myjobs.git myjobs
  cd myjobs
  scl enable git19 -- git checkout tags/v2.1.2
  ```

2. Build the app (install dependencies and build assets)

  ```sh
  scl enable rh-ruby22 git19 -- bin/bundle install --path vendor/bundle
  scl enable rh-ruby22 nodejs010 -- bin/rake assets:precompile RAILS_ENV=production
  scl enable rh-ruby22 -- bin/rake tmp:clear
  ```

3. Copy the built app directory to the deployment directory:
    
  ```sh
  sudo mkdir -p /var/www/ood/apps/sys/myjobs
  sudo rsync -rlptvu . /var/www/ood/apps/sys/myjobs
  ```

4. Access the app through dashboard by going to /pun/sys/dashboard and then clicking "My Jobs" from the Jobs menu

5. (Optional) Add "System" job templates to make available to each user of "My Jobs", i.e.

  ```sh
  # the templates directory is hidden in the .gitignore,
  # so we can pull a directory of templates from another source
  git clone git@github.com:OSC/osc-myjobs-templates.git templates
  ```

## Updating to a New Stable Version

1. Fetch and checkout new version of code:

  ```sh
  cd myjobs # cd to build directory
  scl enable git19 -- git fetch
  scl enable git19 -- git checkout tags/v2.1.2 # check out latest tag
  ```

2. Install gem dependencies and rebuild assets

  ```sh
  scl enable rh-ruby22 -- bin/bundle install --path vendor/bundle
  scl enable rh-ruby22 -- bin/rake tmp:clear
  scl enable rh-ruby22 -- bin/rake assets:clobber RAILS_ENV=production
  scl enable rh-ruby22 nodejs010 -- bin/rake assets:precompile RAILS_ENV=production
  scl enable rh-ruby22 -- bin/rake tmp:clear
  ```

3. Restart app

  ```sh
  touch tmp/restart.txt
  ```

4. Copy the built app directory to the deployment directory. There is no need to restart the server. Because we touched `tmp/restart.txt` in the app, the next time a user accesses an app Passenger will reload their app.


## Usage

"My Jobs" attempts to model a simple but common workflow. When creating a new batch job to run a simulation a user may:

1. copy the directory of a job they already ran or an example job
2. edit the files
3. submit a new job

"My Jobs" implements these steps by providing the user job template directories and the ability to make copies of them.

1. copy the a directory of a job they already ran or an example job

  1. User can create a new job from a "default" template.
  
    1. A custom default template can be defined in `/var/www/ood/apps/sys/myjobs/templates/default`
    2. If no default template is specified, the default is `/var/www/ood/apps/sys/myjobs/example_templates/torque`

  2. user can select a directory to copy from a list of "System" templates the admin copied to `/var/www/ood/apps/sys/myjobs/templates` during installation
  3. user can select a directory to copy from a list of "User" templates that the user has copied to `$HOME/ondemand/data/sys/myjobs/templates`
  4. user can select a job directory to copy that they already created through "My Jobs" from `$HOME/ondemand/data/sys/myjobs/projects/default`

2. edit the files
  1. user can open the copied job directory in the File Explorer and edit files using the File Editor

3. submit a new job
  1. user can use the Job Options form specify which host to submit to, what file is the job script
  2. user can use the web interface to submit the job to the batch system
  3. after the job is completed, the user can open the directory in the file explorer to view results

### Templates

A template consists of a folder and (optionally) a `manifest.yml` file.

The folder contains files and scripts related to the job.

The manifest contains additional metadata about a job, such as a name, the default host, the submit script file name, and any notes about the template.

```
name: A Template Name
host: ruby
script: ruby.sh
notes: Notes about the template, such as content and function.
```

In the event that a job is created from a template that has no `manifest.yml`, or if metadata is missing, "My Jobs" will assign the following default values:

* `name` The name of the template folder.
* `host` The cluster id of the first cluster with a valid resource_mgr listed in the OOD cluster config
* `script` The first `.sh` file appearing in the template folder.
* `notes` The path to the location where a template manifest should be located.
