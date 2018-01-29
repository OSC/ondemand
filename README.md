# OOD Active Jobs

[![GitHub version](https://badge.fury.io/gh/OSC%2Food-activejobs.svg)](https://badge.fury.io/gh/OSC%2Food-activejobs)

Application displays the current system status of jobs running, queued, and
held on the Oakley and Ruby Clusters.

## New Install

**Installation assumptions: you have an Open OnDemand installation with File
Explorer and Shell apps installed and a cluster config added to
/etc/ood/config/clusters.d directory.**

1. Start in the **build directory** for all sys apps, clone and check out the
   latest version of the activejobs app (make sure the app directory's name is
   `activejobs`):

   ```sh
   scl enable git19 -- git clone https://github.com/OSC/ood-activejobs.git activejobs
   cd activejobs
   scl enable git19 -- git checkout tags/v1.6.1
   ```

2. Install the app for a production environment:

   ```sh
   RAILS_ENV=production scl enable git19 rh-ruby22 nodejs010 -- bin/setup
   ```

   this will setup a default Open OnDemand install.

3. Copy the built app directory to the deployment directory, and start the
   server. i.e.:

   ```sh
   sudo mkdir -p /var/www/ood/apps/sys/activejobs
   sudo cp -r . /var/www/ood/apps/sys/activejobs
   ```

## Updating to a New Stable Version

1. Navigate to the app's build directory and check out the latest version:

   ```sh
   cd activejobs # cd to build directory
   scl enable git19 -- git fetch
   scl enable git19 -- git checkout tags/v1.6.1
   ```

2. Update the app for a production environment:

   ```sh
   RAILS_ENV=production scl enable git19 rh-ruby22 nodejs010 -- bin/setup
   ```

3. Copy the built app directory to the deployment directory:

   ```sh
   sudo mkdir -p /var/www/ood/apps/sys/activejobs
   sudo rsync -rlptv --delete . /var/www/ood/apps/sys/activejobs
   ```

## Usage

- Active Jobs displays in a table the jobs currently submitted to the batch
  server.
- The table of jobs can be filtered using the provided filters in the dropdowns
  located in the top right.
- The data is retrieved via an Ajax request but to get updated data you must
  refresh the page.
- Progressive disclosure is used to show details of a job. Click on the "right
  arrow" handle to the left of a table row to show details.

## Configuration

### Custom Filters

Filters can be added by creating a file with the necessary Ruby code under:

```
/etc/ood/config/apps/activejobs/initializers/filters.rb
```

An example of a custom filter is:

```rb
# /etc/ood/config/apps/activejobs/initializers/filters.rb

# Add a filter by group option and insert it after the first option.
Filter.list.insert(1, Filter.new.tap { |f|
  group = OodSupport::User.new.group.name
  f.title = "Your Group's Jobs (#{group})"
  f.filter_id = "group"
  # N.B. Need to use :egroup here for now. My Oodsupport group name is 'appl'
  # but job 'Account_Name' is 'PZS0002'
  f.filter_block = Proc.new { |job| job.native[:egroup] == group }
})
```

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/OSC/ood-activejobs.

## License

The gem is available as open source under the terms of the [MIT
License](http://opensource.org/licenses/MIT).
