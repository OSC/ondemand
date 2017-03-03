# OOD File Editor

[![GitHub version](https://badge.fury.io/gh/osc%2Food-fileeditor.svg)](https://badge.fury.io/gh/osc%2Food-fileeditor)
[![Inline docs](http://inch-ci.org/github/OSC/ood-fileeditor.svg?branch=master)](http://inch-ci.org/github/OSC/ood-fileeditor)

A simple Rails web app that uses https://ace.c9.io/ for editing files. It is meant to be used in conjunction with other Open OnDemand apps, so it provides a URL pattern for opening a file to edit that is exposed via https://github.com/osc/ood_appkit#file-editor-app. Thus, other Open OnDemand apps can easily provide an "open file for editing" link.

* [New Install](#new-install)
* [Updating to a new stable version](#updating-to-a-new-stable-version)
* [Usage](#usage)

![File Explorer Interface](docs/img/001_interface.png)

## New Install

1. Starting in the build directory for all sys apps (i.e. `cd ~/ood_portals/ondemand/sys`), clone and check out the [latest version](https://github.com/OSC/ood-fileeditor/releases) of the file editor:

  ```sh
  scl enable git19 -- git clone https://github.com/OSC/ood-fileeditor.git file-editor
  cd file-editor
  scl enable git19 -- git checkout tags/v1.2.2
  ```
  
2. Build the app (install dependencies and build assets)
 
  ```sh
  scl enable git19 rh-ruby22 nodejs010 -- bin/bundle install --path=vendor/bundle
  scl enable git19 rh-ruby22 nodejs010 -- bin/rake assets:precompile RAILS_ENV=production
  scl enable git19 rh-ruby22 nodejs010 -- bin/rake tmp:clear
  ```
  
3. Copy the built app directory to the deployment directory, and start the server. i.e.:
    
  ```sh
  sudo mkdir -p /var/www/ood/apps/sys/file-editor
  sudo rsync -rlptvu . /var/www/ood/apps/sys/file-editor
  ```
  
## Updating to a new stable version

[_See wiki for OSC specific installation and update instructions_](https://github.com/OSC/ood-fileeditor/wiki)

1. Navigate to the app installation and check out the [latest version]((https://github.com/OSC/ood-fileeditor/releases)).

  ```sh
  scl enable git19 rh-ruby22 nodejs010 -- git pull
  scl enable git19 rh-ruby22 nodejs010 -- git checkout tags/v1.2.2  # use the latest tag
  ```
  
2. Install gem dependencies and rebuild assets

  ```sh
  scl enable git19 rh-ruby22 nodejs010 -- bin/bundle install --path=vendor/bundle
  scl enable git19 rh-ruby22 nodejs010 -- bin/rake assets:clobber
  scl enable git19 rh-ruby22 nodejs010 -- bin/rake assets:precompile RAILS_ENV=production
  scl enable git19 rh-ruby22 nodejs010 -- bin/rake tmp:clear
  ```
  
3. Restart the app
  
  ```sh
  scl enable git19 rh-ruby22 nodejs010 -- touch tmp/restart.txt
  ```
  
## Usage

### File access
    
* Access files via `APP_PATH` + `/edit` + `FILE_PATH`
    * Example `https://ondemand3.osc.edu/pun/sys/file-editor/edit/nfs/08/bmcmichael/Files/tire.k`

### Directory access

The app provides a rudimentary file explorer in the case that a folder is accessed instead of a directory. If the path is readable to the user, it will be displayed when accessed.

* Access readable folder contents via `APP_PATH` + `/edit` + `FOLDER_PATH`
    * Example `https://ondemand3.osc.edu/pun/sys/file-editor/edit/nfs/08/bmcmichael/Files/`
    
