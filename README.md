## Deployment directions

Log in as `wiag` user

```
$ cd /nfs/01/wiag/PZS0645/ood/apps/sys
$ git clone https://github.com/AweSim-OSC/osc-fileexplorer.git files
$ npm i
```

A `sudo` user will then need to copy this folder to the production environment.

## Updating after modifications to OSC/cloudcmd dependency

After updates to OSC/cloudcmd are made, tag a release version and update the `package.json` file in the root of the `osc-fileexplorer` repository.

`package.json`

```
  "dependencies": {
    ...
    "cloudcmd": "git://github.com/OSC/cloudcmd.git#v5.3.1-osc.5",
    ...
```

Where `v5.3.1-osc-5` is the current release tag of the OSC/cloudcmd repo.

Then to update you will need to remove the node shrinkwrap and update the dependencies:

```
$ rm npm-shrinkwrap.json
$ npm update
$ npm shrinkwrap
```
