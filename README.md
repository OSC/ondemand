## Deployment directions

Log in as `wiag` user

```
$ cd /nfs/01/wiag/PZS0645/ood/apps/sys
$ git clone https://github.com/AweSim-OSC/osc-fileexplorer.git files
$ npm install
$ mkdir tmp
$ touch tmp/restart.txt
```

A `sudo` user will then need to copy this folder to the production environment.

## Updating after modifications to OSC/cloudcmd dependency

After updates to OSC/cloudcmd are made, tag a release version to OSC/cloudcmd (tag off of the osc-5.3.1 branch in the format v5.3.1-osc.7 where 7 is replaced with a number representing the latest version).

Then checkout the latest commit of the osc-fileexplorer master and update it to use the latest version:

```bash
npm install # install current versions being used
npm install git://github.com/osc/cloudcmd#v5.3.1-osc.7 --save # install the version you want
npm shrinkwrap
```

Both the npm-shrinkwrap.json and the package.json files should be updated. Commit those to osc-fileexplorer, then add a new release tag to osc-fileexplorer.
