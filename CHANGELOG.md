# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## Upcoming

- Fix crash when the git folder is not present

## v1.3.6 - 2017-10-24

- update to osc/cloudcmd v5.3.1-osc.29
  - Open html and pdf files in a new tab
- update cloudcmd dependencies 

## v1.3.5 - 2017-06-30

- update to osc/cloudcmd v5.3.1-osc.28
  - Fixes a silent delete bug in cloudcmd

## v1.3.4 [YANKED]

- update to osc/cloudcmd v5.3.1-osc.27

## v1.3.3

- update to osc/cloudcmd v5.3.1-osc.26

## v1.2.1

- Add IE download fix for fallback downloader when nginx stage not configured

## v1.2.0 - 2016-10-27

Features:

  - Removed Passenger overhead for large file downloads by leveraging https://github.com/OSC/nginx_stage

## v1.1.1

Features:

  - new downloading scheme for large file download support

Bugfixes: 

  - IE 11 font caching fix
  - fix Chrome warning for deprecated method

## v1.1.0
 
Features:
 
  - MIT License
  - documentation with images in README
  
Bugfixes:  
  
  - updated cloudcmd dependency to address bugfixes in v5.3.1-osc.15 and v5.3.1-osc.16
  
## v1.0.0

Initial Release
