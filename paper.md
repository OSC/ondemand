---
title: 'Open OnDemand: A web-based client portal for HPC centers'
tags:
  - HPC
  - apps
  - portal
  - gateway
  - web platform
authors:
 - name: Dave Hudak
   orcid: https://orcid.org/0000-0002-9043-0850
   affiliation: 1
 - name: Doug Johnson
   orcid: https://orcid.org/0000-0002-4331-8508
   affiliation: 1
 - name: Alan Chalker
   orcid: https://orcid.org/0000-0002-5475-8779
   affiliation: 1
 - name: Jeremy Nicklas
   orcid: https://orcid.org/0000-0003-3208-7588
   affiliation: 1
 - name: Eric Franz
   orcid: https://orcid.org/0000-0002-9662-412X
   affiliation: 1
 - name: Trey Dockendorf
   orcid: https://orcid.org/0000-0002-5494-0968
   affiliation: 1
 - name: Brian L. McMichael
   orcid: https://orcid.org/0000-0001-7455-6691
   affiliation: 1
affiliations:
 - name: The Ohio Supercomputer Center
   index: 1
date: 8 March 2018
bibliography: paper.bib
---

# Summary

The web has become the dominant access mechanism for remote compute services in
every computing area except high-performance computing (HPC). Accessing HPC
resources, either at the campus or national level typically requires advanced
knowledge of Linux, familiarity with command-line interfaces and installation
and configuration of custom client software (e.g., Secure Shell (SSH) and
Virtual Network Computing (VNC)). These additional requirements create an
accessibility gap for HPC. To help address this gap we have created the Open
OnDemand Project [@Hudak2016], an open-source software project based on the
proven Ohio Supercomputer Center (OSC) OnDemand platform [@Hudak2013], to allow
HPC centers to provide advanced web and graphical interfaces for their users.

Open OnDemand is the result of substantial development and integration efforts
in four key areas. (1) The per-user NGINX (PUN) architecture including
federated authentication using CILogon, Apache-based web proxy, per-user NGINX
configuration, and Unix domain sockets for secure server-side communication
between the proxy and each PUN. The PUN architecture is an original
contribution of the project. (2) The file browser and file editor which, though
originally based on an existing open source project, have been extensively
modified. (3) The terminal, created by integrating an existing open source
project with minimal effort. (4) Accessibility Apps (Dashboard, Job
Constructor, Job Status, System Status, VDI and iHPC apps) built using the
Rails-based AweSim AppKit (which was developed by this team on a previous
project and leveraged here with minor modifications). The AweSim AppKit allows
for the development of both workflow and interactive applications and includes
mechanisms for user-based app creation, app sharing and app publishing. The
AppKit technology is included as part of the Open OnDemand project.

# Acknowledgements

This work is supported by the National Science Foundation of the United States under the award NSF SI2-SSE-1534949.

# References
