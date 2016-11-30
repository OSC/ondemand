# OOD File Explorer

[![GitHub version](https://badge.fury.io/gh/OSC%2Food-fileexplorer.svg)](https://badge.fury.io/gh/OSC%2Food-fileexplorer)

A Node.js web based file explorer that is a modification of [CloudCommander](http://cloudcmd.io/) with a focus on a user friendly interface for file uploads, downloads, editing, renaming and copying. It is an Open OnDemand app that is meant to be run as the user.

* [New Install](#new-install)
* [Updating to a new stable version](#updating-to-a-new-stable-version)
* [Usage](#usage)
    * [API](#api)

## Features

* Create Files/Folders
* View Files
* Edit Files (with [OOD File Editor](https://github.com/OSC/ood-fileeditor) configured)
* Rename/Copy/Paste/Delete Files
* Upload large files
* Download files
* Launch Terminal in location (with [OOD Shell](https://github.com/OSC/ood-shell) configured)

![File Explorer Interface](docs/img/001_interface.png)

## New Install

1. Starting in the build directory for all sys apps (i.e. `cd ~/ood_portals/ondemand/sys`), clone and check out the [latest version](https://github.com/OSC/ood-fileexplorer/releases) of the file explorer:

  ```sh
  scl enable git19 rh-ruby22 nodejs010 -- git clone https://github.com/OSC/ood-fileexplorer.git files
  scl enable git19 rh-ruby22 nodejs010 -- cd files
  scl enable git19 rh-ruby22 nodejs010 -- git checkout tags/v1.3.0  # use the latest tag
  ```

2. Update the environment variables as appropriate.

  * Copy the `.env.example` to `.env` and configure the environment for the system.
  
    ```sh
    cp .env.example .env
    ```
    
  * Edit the variables in `.env` as appropriate for your system.
    
    ```sh
    # The uri path to the ood-fileeditor app (if installed) [Default: ""]
    OOD_FILE_EDITOR='/pun/sys/file-editor/edit'
    
    # The uri path to the ood-shell app (if installed) [Default: ""]
    OOD_SHELL='/pun/sys/shell/ssh/default'
    
    # The maximum file upload size as integer (in bytes) [Default: 2097152000]
    FILE_UPLOAD_MAX=10485760000
    ```
  
    * Update `OOD_FILE_EDITOR` to the path of the system installed [`ood-fileeditor`](https://github.com/OSC/ood-fileeditor) application. If this value is not configured, the option to edit files will not be available in the File Explorer.
  
    * Update `OOD_SHELL` to the path of the system installed [`ood-shell`](https://github.com/OSC/ood-shell) application. If this value is not configured, the option to open a terminal in the current directory will not be available in the File Explorer.
  
    * Update `FILE_UPLOAD_MAX` to be the maximum allowable upload size (in bytes) for file uploads in the app. If a user attempts to exceed this value, the upload will be blocked. Uploads are processed in `/var/tmp` by the Passenger process, so uploads will be practically limited by the available space in this location. It is recommended that this value be less than half of the available space in `/var/tmp`, or less, to allow for concurrent uploaders. If this value is not configured, the default will be 2 GB.
  
3. Build the app (install dependencies and build assets)
 
  ```sh
  scl enable git19 rh-ruby22 nodejs010 -- npm i
  ```
  
## Updating to a new stable version

[_See wiki for OSC specific installation and update instructions_](https://github.com/OSC/ood-fileexplorer/wiki)

1. Navigate to the app installation and check out the [latest version]((https://github.com/OSC/ood-fileexplorer/releases)).

  ```sh
  scl enable git19 rh-ruby22 nodejs010 -- git pull
  scl enable git19 rh-ruby22 nodejs010 -- git checkout tags/v1.3.0  # use the latest tag
  ```
  
2. Install node dependencies reinstall modules

  ```sh
  scl enable git19 rh-ruby22 nodejs010 -- npm update
  ```
  
3. Restart the app
  
  ```sh
  scl enable git19 rh-ruby22 nodejs010 -- touch tmp/restart.txt
  ```
  
## Usage

For general usage instructions see: https://www.osc.edu/supercomputing/ondemand/file-transfer-and-management

### API

The File Explorer contains a node-js REST API based on the [`node-restafary`](https://github.com/coderaiser/node-restafary) package, which can be used by other applications in the OnDemand Environment.

|URL                            |HTTP Verb   |Body               |Description                    |
|:------------------------------|:-----------|:------------------|:------------------------------|
|`/api/v1/fs/<path>`            |`GET`       |                   | get file or dir content       |
|`/api/v1/fs/<path>?size`       |`GET`       |                   | get file or dir size          |
|`/api/v1/fs/<path>?time`       |`GET`       |                   | get time of file or dir change|
|`/api/v1/fs/<path>?hash`       |`GET`       |                   | get file hash (SHA-1)         |
|`/api/v1/fs/<path>?beautify`   |`GET`       |                   | beautify js, html, css        |
|`/api/v1/fs/<path>?minify`     |`GET`       |                   | minify js, html, css          |
|`/api/v1/fs/<path>`            |`PUT`       | file content      | create/write file             |
|`/api/v1/fs/<path>?unzip`      |`PUT`       | file content      | unzip and create/write file   |
|`/api/v1/fs/<path>?dir`        |`PUT`       |                   | create dir                    |
|`/api/v1/fs/<path>`            |`PATCH`     | diff              | patch file                    |
|`/api/v1/fs/<path>`            |`DELETE`    |                   | delete file                   |
|`/api/v1/fs/<path>?files`      |`DELETE`    | array of names    | delete files                  |

#### Example:

GET requests will follow the pattern `App Root` + `api/v1/fs/` + `File Path`, where File Path will be the absolute path of a file on the system.

* To GET a file named `/users/appl/bmcmichael/.gitconfig` at the OSC deployment of OnDemand, the link would be:
  * `https://ondemand3.osc.edu/pun/sys/files/api/v1/fs/users/appl/bmcmichael/.gitconfig`
    * App Root: `https://ondemand3.osc.edu/pun/sys/files/`
    * API Route: `api/v1/fs/`
    * File Path: `/users/appl/bmcmichael/.gitconfig`

Since the application is running as the logged in user, the application will only have access to the files that the user actually has access to within the file system.
