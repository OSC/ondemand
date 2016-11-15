# OOD File Explorer

A Node.js web based file explorer that is a modification of [CloudCommander](http://cloudcmd.io/) with a focus on a user friendly interface for file uploads, downloads, editing, renaming and copying. It is an Open OnDemand app that is meant to be run as the user.

![File Explorer Interface](docs/img/001_interface.png)

## Features

* Create Files/Folders
* View Files
* Edit Files (with [OOD File Editor](https://github.com/OSC/ood-fileeditor) configured)
* Rename/Copy/Paste/Delete Files
* Upload large files
* Download files
* Launch Terminal in location (with [OOD Shell](https://github.com/OSC/ood-shell) configured)

## Quick Installation

1. Navigate to the OOD system apps staged deployment path.
2. Clone the `OSC/ood-fileexplorer.git` repository.
3. Rename the `ood-fileexplorer` folder to `files` 
4. `git checkout` the latest [release tag](https://github.com/OSC/ood-fileexplorer/releases)
5. Modify environment variables in `.env` as appropriate.
6. Run `scl enable nodejs010 -- npm install`
7. `touch tmp/restart.txt`
8. Copy the project to the production space.

## Detailed Instructions

### Step One: Navigate to the OOD apps staged deployment path.

On the OOD development server, navigate to the folder where the system applications are stored.
 
The system applications are configured by the OOD administrator. If you aren't sure where your deployment is located, please see the documentation for your particular installation or contact your OOD administrator.

If preparing this as a system app, the path will likely be `/<OOD_PORTAL>/sys`

For development apps, `~<username>/<OOD_PORTAL>/dev`

* Paths may vary based on your system configuration.

### Step Two: Clone the `OSC/ood-fileexplorer.git` repository.

File Explorer is a Node.js application that runs as a Passenger process on OOD. You will need to acquire the code via a Githu repository.

Clone the repository:

```
$ git clone https://github.com/OSC/ood-fileexplorer.git files
```

* Note: this will clone the File Explorer application into a folder named `files`, which is the recommended path for interoperability with other OOD applications.
    

### Step Three: Rename the `ood-fileexplorer` folder to `files`

If deploying File Explorer as a system app, rename the `ood-fileexplorer` folder to `files` if you haven't already done so.

* Many applications are configured to look for the files application under this path. It is recommended that you use this path to avoid having to reconfigure other system applications with the alternate path.

* If you are preparing `ood-fileexplorer` as a development app or shared app, you can name the folder whatever you like. The `files` path is suggested as a reliable location for interoperability with other system apps.

### Step Four: `git checkout` the latest [release tag](https://github.com/OSC/ood-fileexplorer/releases)

Ensure that you check out the lastest release tag. The `master` branch may have unreleased modifications that have not been thoroughly tested in production. The master branch should therefore be considered a beta state.
 
* Visit the [Releases](https://github.com/OSC/ood-fileexplorer/releases) page at Github and find the tag of the latest released version of `ood-fileexplorer`.
 
* Check out the latest branch.

```
$ git checkout v1.2.0
```

Replace `v1.2.0` with the latest tag (if applicable). 

### Step Five: Modify environment variables in .env as appropriate.
 
The .env file will contain the configuration information for locally installed dependent applications.

``` 
# The uri path to the ood-fileeditor app (if installed)
OOD_FILE_EDITOR='/pun/sys/file-editor/edit'

# The uri path to the ood-shell app (if installed)
OOD_SHELL='/pun/sys/shell/ssh/default'
```

* Update `OOD_FILE_EDITOR` to the path of the system installed [`ood-fileeditor`](https://github.com/OSC/ood-fileeditor) application. If this value is not configured, the option to edit files will not be available in the File Explorer.

* Update `OOD_SHELL` to the path of the system installed [`ood-shell`](https://github.com/OSC/ood-shell) application. If this value is not configured, the option to open a terminal in the current directory will not be available in the File Explorer.

* Update `FILE_UPLOAD_MAX` to be the maximum allowable upload size (in bytes) for file uploads in the app. If a user attempts to exceed this value, the upload will be blocked. Uploads are processed in `/var/tmp` by the Passenger process, so uploads will be practically limited by the available space in this location. It is recommended that this value be less than half of the available space in `/var/tmp`, or less, to allow for concurrent uploaders. If this value is not configured, the default will be 2 GB.

### Step Six: Run `scl enable nodejs010 -- npm install`
 
 OOD uses [Software Collections](https://www.softwarecollections.org/en/) to maintain consistency among deployments. Your system administrator will have installed the `nodejs010` package as part of the infrastructure deployment process. We use that package to install the File Explorer dependencies via [`npm`](https://www.npmjs.com/).
  
```
$ scl enable nodejs010 -- npm install
```

Wait while the dependencies are download and installed.

Once completed, you will be returned to the command line.

### Step Seven: Restart the app.

Passenger will restart the application for all users if there is an empty file named `restart.txt` in the `tmp/` folder.

Simply `touch` this file to update the timestamp. The application process will then restart the next time that it is loaded.

```
$ touch tmp/restart.txt
```

### Test in development or copy to the production space.

If you have deployed the application in development space, it should be available immediately.

Navigate your browser to the development site:

* `https://<YOUR_OOD_DEVELOPMENT_SERVER/pun/dev/files`

If you've deployed files as a system app, you may need to sync the folder to the production environment.

* Contact your system administrator to sync the folder to production if you do not have access to do so.
 
 
## OSC Specific Installation

Log in as `wiag` user

```
$ cd ~wiag/ood_portals/ondemand/sys
$ git clone git@github.com:OSC/ood-fileexplorer.git files
$ git checkout v1.2.0 # or whatever the lastest release tag is
$ touch .env
```

Rename the `.env.ondemand` file to `.env` and modify paths for the following environment variables with appropriate values.

```
# The uri path to the ood-fileeditor app (if installed)
OOD_FILE_EDITOR='/pun/sys/file-editor/edit'

# The uri path to the ood-shell app (if installed)
OOD_SHELL='/pun/sys/shell/ssh/default'
```

```
$ scl enable nodejs010 -- npm install
$ mkdir tmp
$ touch tmp/restart.txt
```

A `sudo` user will then need to copy this folder to the production environment.

## Deployment directions - updating a deployed instance

When updating a deployed instance of the file explorer - you will have already check out a tag:

```
$ cd /nfs/01/wiag/PZS0645/ood/apps/sys/files
$ git fetch
$ git checkout v1.2.0 # checkout lastest tag
$ rm -rf node_modules
$ scl enable nodejs010 -- npm install
$ touch tmp/restart.txt
```

## Updating after modifications to OSC/cloudcmd dependency

After updates to OSC/cloudcmd are made, tag a release version to OSC/cloudcmd (tag off of the `osc-5.3.1` branch in the format `v5.3.1-osc.20` where `20` is replaced with a number representing the latest version).

Then checkout the latest commit of the ood-fileexplorer master and update it to use the latest version:

```bash
rm npm-shrinkwrap.json # remove the old shrinkwrap file that locks the dependency versions
npm install # install current versions being used
npm install git://github.com/OSC/cloudcmd#v5.3.1-osc.20 --save # install the version you want
npm shrinkwrap # re-write the npm shrinkwrap file
```

Both the `npm-shrinkwrap.json` and the `package.json` files should be updated. Commit those to `ood-fileexplorer`, then add a new release tag to `ood-fileexplorer`.

## Usage

### General

The OOD File Explorer is the web-based file management solution for the Open Ondemand Project.

* View/Edit Files
* Upload/Download Files
* Create/Delete Files/Directories
* Terminal Access
* Editor Access

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
