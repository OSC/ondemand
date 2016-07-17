# OOD File Explorer

A Node.js web based file explorer that is a modification of [CloudCommander](http://cloudcmd.io/) with a focus on a user friendly interface for file uploads, downloads, editing, renaming and copying. It is an Open OnDemand app that is meant to be run as the user.

## Install

**NOTE: these are OSC specific installation directions. Directions more appropriate for Open OnDemand will be added soon.**

Log in as `wiag` user

```
$ cd /nfs/01/wiag/PZS0645/ood/apps/sys
$ git clone git@github.com:AweSim-OSC/osc-fileexplorer.git files
$ git checkout v1.0.0 # or whatever the lastest release tag is
$ touch .env
```

Edit the `.env` file and add paths for the following environment variables, replace paths with appropriate values.

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
$ git checkout v1.0.3 # checkout lastest tag
$ rm -rf node_modules
$ npm install
$ touch tmp/restart.txt
```

## Updating after modifications to OSC/cloudcmd dependency

After updates to OSC/cloudcmd are made, tag a release version to OSC/cloudcmd (tag off of the osc-5.3.1 branch in the format v5.3.1-osc.7 where 7 is replaced with a number representing the latest version).

Then checkout the latest commit of the osc-fileexplorer master and update it to use the latest version:

```bash
npm install # install current versions being used
npm install git://github.com/osc/cloudcmd#v5.3.1-osc.7 --save # install the version you want
npm shrinkwrap
```

Both the npm-shrinkwrap.json and the package.json files should be updated. Commit those to osc-fileexplorer, then add a new release tag to osc-fileexplorer.
