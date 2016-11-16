# OOD File Editor

A simple Rails web app that uses https://ace.c9.io/ for editing files. It is meant to be used in conjunction with other Open OnDemand apps, so it provides a URL pattern for opening a file to edit that is exposed via https://github.com/osc/ood_appkit#file-editor-app. Thus, other Open OnDemand apps can easily provide an "open file for editing" link.

* [New Install]()
* [Updating to a new stable version]()
* [Usage]()

![File Explorer Interface](docs/img/001_interface.png)

## New Install

1. Navigate to the OOD apps staged deployment path.
2. Clone the `OSC/ood-fileeditor.git` repository.
3. `cd` into the cloned directory.
4. `git checkout` the latest [release tag](https://github.com/OSC/ood-fileeditor/releases)
  * `$ git checkout v1.0.2  # use the latest tag`
5. Run bundle install, use path `vendor/bundle`
  * `$ scl enable git19 rh-ruby22 nodejs010 -- bin/bundle install --path=vendor/bundle`
6. Build the assets
  * `$ scl enable git19 rh-ruby22 nodejs010 -- bin/rake assets:precompile RAILS_ENV=production`
7. Clear the cache
  * `$ scl enable git19 rh-ruby22 nodejs010 -- bin/rake tmp:clear`
8. Restart the app
  * `$ touch tmp/restart.txt`
  
## Updating to a new stable version

1. `cd` into the app directory.
2. `git checkout` the latest [release tag](https://github.com/OSC/ood-fileeditor/releases)
  * `$ git checkout v1.0.2  # use the latest tag`
3. Run bundle install, use path `vendor/bundle`
  * `$ scl enable git19 rh-ruby22 nodejs010 -- bin/bundle install --path=vendor/bundle`
4. Clobber the existing assets
  * `$ scl enable git19 rh-ruby22 nodejs010 -- bin/rake assets:clobber`
5. Build the assets
  * `$ scl enable git19 rh-ruby22 nodejs010 -- bin/rake assets:precompile RAILS_ENV=production`
6. Clear the cache
  * `$ scl enable git19 rh-ruby22 nodejs010 -- bin/rake tmp:clear`
7. Restart the app  
  * `$ touch tmp/restart.txt`
  
  
## TODO move OSC-specific guide elsewhere 
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



### File access
    
* Access files via `APP_PATH` + `/edit` + `FILE_PATH`
    * Example `https://ondemand3.osc.edu/pun/sys/file-editor/edit/nfs/08/bmcmichael/Files/tire.k`

### Directory access

The app provides a rudimentary file explorer in the case that a folder is accessed instead of a directory. If the path is readable to the user, it will be displayed when accessed.

* Access readable folder contents via `APP_PATH` + `/edit` + `FOLDER_PATH`
    
