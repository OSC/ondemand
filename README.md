# Job Composer (renamed from My Jobs)

[![GitHub version](https://badge.fury.io/gh/OSC%2Food-myjobs.svg)](https://badge.fury.io/gh/OSC%2Food-myjobs)

OOD Rails app for Open OnDemand for creating and managing batch jobs from template directories.

## New Install

**Installation assumptions: you have an Open OnDemand installation with File
Explorer and Shell apps installed and a cluster config added to
/etc/ood/config/clusters.d directory.**

1. Start in the **build directory** for all sys apps, clone and check out the
   latest version of the myjobs app (make sure the app directory's name is
   `myjobs`):

   ```sh
   scl enable git19 -- git clone https://github.com/OSC/ood-myjobs.git myjobs
   cd myjobs
   scl enable git19 -- git checkout tags/v2.7.0
   ```

2. Install the app for a production environment:

   ```sh
   RAILS_ENV=production scl enable git19 rh-ruby22 nodejs010 -- bin/setup
   ```

   this will setup a default Open OnDemand install. If you'd like a specific
   pre-defined portal such as OSC OnDemand you'd specify `OOD_SITE` and
   `OOD_PORTAL` as:

   ```sh
   OOD_SITE=osc OOD_PORTAL=ondemand RAILS_ENV=production scl enable git19 rh-ruby22 nodejs010 -- bin/setup
   ```

   assuming the corresponding `.env.local.$OOD_SITE.$OOD_PORTAL` file exists.

3. (Optional) Add "System" job templates to make available to each user of "My
   Jobs", i.e.

   ```sh
   # the templates directory is hidden in the .gitignore,
   # so we can pull a directory of templates from another source
   # this is an example of deploying OSC's templates it provides to its users
   git clone https://github.com/OSC/osc-myjobs-templates.git templates
   ```

4. Copy the built app directory to the deployment directory, and start the
   server. i.e.:

   ```sh
   sudo mkdir -p /var/www/ood/apps/sys/myjobs
   sudo cp -r . /var/www/ood/apps/sys/myjobs
   ```

## Updating to a New Stable Version

1. Navigate to the app's build directory and check out the latest version:

   ```sh
   cd myjobs # cd to build directory
   scl enable git19 -- git fetch
   scl enable git19 -- git checkout tags/v2.7.0
   ```

2. Update the app for a production environment:

   ```sh
   RAILS_ENV=production scl enable git19 rh-ruby22 nodejs010 -- bin/setup
   ```

   You do not need to specify `OOD_SITE` and `OOD_PORTAL` if they are defined
   in the `.env.local` file.

3. Copy the built app directory to the deployment directory:

   ```sh
   sudo rsync -rlptv --delete . /var/www/ood/apps/sys/myjobs
   ```

## Usage

"Job Composer" attempts to model a simple but common workflow. When creating a new batch job to run a simulation a user may:

1. copy the directory of a job they already ran or an example job
2. edit the files
3. submit a new job

"Job Composer" implements these steps by providing the user job template directories and the ability to make copies of them.

1. copy the a directory of a job they already ran or an example job

  1. User can create a new job from a "default" template.

    1. A custom default template can be defined at `/etc/ood/config/apps/myjobs/templates/default` or under the app deployment directory at `/var/www/ood/apps/sys/myjobs/templates/default`
    2. If no default template is specified, the default is `/var/www/ood/apps/sys/myjobs/example_templates/torque`

  2. user can select a directory to copy from a list of "System" templates the admin copied to `/etc/ood/config/apps/myjobs/templates` or under the app deployment directory at `/var/www/ood/apps/sys/myjobs/templates` during installation
  3. user can select a directory to copy from a list of "User" templates that the user has copied to `$HOME/ondemand/data/sys/myjobs/templates`
  4. user can select a job directory to copy that they already created through "Job Composer" from `$HOME/ondemand/data/sys/myjobs/projects/default`

2. edit the files
  1. user can open the copied job directory in the File Explorer and edit files using the File Editor

3. submit a new job
  1. user can use the Job Options form specify which host to submit to, what file is the job script
  2. user can use the web interface to submit the job to the batch system
  3. after the job is completed, the user can open the directory in the file explorer to view results

### Templates

A template consists of a folder and a `manifest.yml` file.

The folder contains files and scripts related to the job.

The manifest contains additional metadata about a job, such as a name, the default host, the submit script file name, and any notes about the template.

```
name: A Template Name
host: ruby
script: ruby.sh
notes: Notes about the template, such as content and function.
```

In the event that a job is created from a template that is missing from the `manifest.yml`, "Job Composer" will assign the following default values:

* `name` The name of the template folder.
* `host` The cluster id of the first cluster with a valid resource_mgr listed in the OOD cluster config
* `script` The first `.sh` file appearing in the template folder.
* `notes` The path to the location where a template manifest should be located.

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/OSC/ood-myjobs.

## License

The gem is available as open source under the terms of the [MIT
License](http://opensource.org/licenses/MIT).
