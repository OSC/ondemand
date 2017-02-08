# OOD My Jobs

Rails app for Open OnDemand for creating and managing batch jobs from template directories.

## New Install

1. Starting in the build directory for all sys apps (i.e. `cd ~/ood_portals/ondemand/sys`), clone and check out the latest version of myjobs (make sure the app directory's name is "myjobs"):

  ```sh
  scl enable git19 -- git clone https://github.com/OSC/ood-myjobs.git myjobs
  cd myjobs
  scl enable git19 -- git checkout tags/LATEST
  ```

**TODO: fix tags/LATEST to whatever the latest tag is**

2. Build the app

3. Add cluster config if not provided. **TODO**

4. Add extra templates**TODO**

5. Copy the built app directory to the deployment directory, and start the OOD server.

6. Access My Jobs by going to the dashboard and launching it from there.

## Updating to a New Stable Version

**TODO**

# Old documentation

**TODO** - replace with updated documentation

* default template
* templates/ directory and osc-myjobs-templates example repo
* template manifest

## Templates

A template consists of a folder and (optionally) a `manifest.yml` file.

The folder contains files and scripts related to the job.

The manifest contains additional metadata about a job, such as a name, the default host, the submit script file name, and any notes about the template.

## Building a Template

Prepare a manifest with `name` (string), `host` (string \[options: `oakley` or `ruby`\]), `script` (string \[the relative path of the file to be submitted\]), and `notes` (string) variables and name it `manifest.yml`

```
name: A Template Name
host: ruby
script: ruby.sh
notes: Notes about the template, such as content and function.
```

## Template Defaults

In the event that a folder exists in the template source location but no `manifest.yml` is present, or if the variables missing, the Job Constructor will assign the following default values:

* `name` The name of the template folder.
* `host` The first server listed in `config/servers.yml` (Currently Oakley)
* `script` The first `.sh` file appearing in the template folder.
* `notes` The path to the location where a template manifest should be located.
