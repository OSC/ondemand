# OOD File Explorer

A Node.js web based file explorer that is a modification of [CloudCommander](http://cloudcmd.io/) with a focus on a user friendly interface for file uploads, downloads, editing, renaming and copying. It is an Open OnDemand app that is meant to be run as the user.

![File Explorer Interface](docs/img/001_interface.png)

## Install

1. Navigate to the OOD apps staged deployment path.
2. Clone the `OSC/ood-fileexplorer.git` reposititory.
3. `git checkout` the latest [release tag](https://github.com/OSC/ood-fileexplorer/releases)
4. Create a `.env` file or rename `.env.ondemand` to `.env` and modify environment variables.
5. Run `npm install`
6. `mkdir tmp`
7. `touch tmp/restart.txt`
8. Copy the project to the production space.
 
### OSC Specific Installation

Log in as `wiag` user

```
$ cd /nfs/01/wiag/PZS0645/ood/apps/sys
$ git clone git@github.com:OSC/ood-fileexplorer.git files
$ git checkout v1.0.5 # or whatever the lastest release tag is
$ touch .env
```

Rename the `.env.ondemand` file to `.env` and modify paths for the following environment variables with appropriate values.

```
OOD_FILE_EDITOR='/pun/sys/file-editor/edit'
OOD_SHELL='/pun/sys/shell/ssh/default'
```

```
$ npm install
$ mkdir tmp
$ touch tmp/restart.txt
```

A `sudo` user will then need to copy this folder to the production environment.

## Deployment directions - updating a deployed instance

When updating a deployed instance of the file explorer - you will have already check out a tag:

```
$ cd /nfs/01/wiag/PZS0645/ood/apps/sys/files
$ git pull # this will pull updated tags etc but not modify current working directory if current directory is a tag
$ git checkout v1.0.5 # checkout lastest tag
$ rm -rf node_modules
$ npm install
$ touch tmp/restart.txt
```

## Updating after modifications to OSC/cloudcmd dependency

After updates to OSC/cloudcmd are made, tag a release version to OSC/cloudcmd (tag off of the osc-5.3.1 branch in the format v5.3.1-osc.12 where 12 is replaced with a number representing the latest version).

Then checkout the latest commit of the ood-fileexplorer master and update it to use the latest version:

```bash
rm npm-shrinkwrap.json # remove the old shrinkwrap file that locks the dependency versions
npm install # install current versions being used
npm install git://github.com/OSC/cloudcmd#v5.3.1-osc.12 --save # install the version you want
npm shrinkwrap # re-write the npm shrinkwrap file
```

Both the npm-shrinkwrap.json and the package.json files should be updated. Commit those to ood-fileexplorer, then add a new release tag to ood-fileexplorer.

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
