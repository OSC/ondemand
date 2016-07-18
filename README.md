# OOD File Editor

A simple Rails web app that uses https://ace.c9.io/ for editing files. It is meant to be used in conjunction with other Open OnDemand apps, so it provides a URL pattern for opening a file to edit that is exposed via https://github.com/osc/ood_appkit#file-editor-app. Thus, other Open OnDemand apps can easily provide an "open file for editing" link.

![File Explorer Interface](docs/img/001_interface.png)

## Install

1. Navigate to the OOD apps staged deployment path.
2. Clone the `OSC/ood-fileeditor.git` reposititory.
3. `cd` into the cloned directory.
4. `git checkout` the latest [release tag](https://github.com/OSC/ood-fileeditor/releases)
5. Run bundle install, use path `vendor/bundle`
  * `bin/bundle install --path=vendor/bundle`
6. Build the assets
  * RAILS_ENV=production bin/rake assets:precompile
7. Clear the cache
  * `bin/rake tmp:clear`
 
#### On OSC Systems, the following commands replicate the above steps.

```bash
$ cd /nfs/gpfs/PZS0645/ood/apps/sys
$ git clone git@github.com:OSC/ood-fileeditor.git file-editor
$ git checkout v1.0.2  # use the latest tag
$ cd file-editor

# bundle install gems into app subdir
$ bin/bundle install --path vendor/bundle

# build assets
$ RAILS_ENV=production bin/rake assets:precompile
$ bin/rake tmp:clear
```

## Usage

Access files via `APP_PATH` + `/edit` + `FILE_PATH`

Ex.

`https://ondemand3.osc.edu/pun/sys/file-editor/edit/nfs/08/bmcmichael/Files/tire.k`
