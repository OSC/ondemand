# OSC Job Constructor

## Templates

A template consists of a folder and (optionally) a `manifest.yml` file.

The folder contains files and scripts related to the job.

The manifest contains additional metadata about a job, such as a name, the default host, the submit script file name, and any notes about the template.

Prepare a manifest with `name` (string), `host` (string \[options: `oakley` or `ruby`\]), `script` (string \[the relative path of the file to be submitted\]), and `notes` (string) variables and name it `manifest.yml`

```
name: A Template Name
host: ruby
script: ruby.sh
notes: Notes about the template, such as content and function.
```

In the event that a folder exists in the template source location but no `manifest.yml` is present, or if the variables missing, the Job Constructor will assign the following default values:

* `name` The name of the template folder.
* `host` The first server listed in `config/servers.yml` (Currently Oakley)
* `script` The first `.sh` file appearing in the template folder.
* `notes` The path to the location where a template manifest should be located.

## Building a Template

Default Template files located in `/nfs/01/wiag/PZS0645/oos/jobs/templates`
