# OOD File Editor

A simple Rails web app that uses https://ace.c9.io/ for editing files. It is meant to be used in conjunction with other Open OnDemand apps, so it provides a URL pattern for opening a file to edit that is exposed via https://github.com/osc/ood_appkit#file-editor-app. Thus, other Open OnDemand apps can easily provide an "open file for editing" link.

![File Explorer Interface](docs/img/001_interface.png)

## Install

**TODO**

## Usage

Access files via `APP_PATH` + `/edit` + `FILE_PATH`

Ex.

`https://ondemand3.osc.edu/pun/sys/file-editor/edit/nfs/08/bmcmichael/Files/tire.k`
