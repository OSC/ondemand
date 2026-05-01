<div align="center">

<img src="https://openondemand.org/sites/default/files/svgs/ood-logo.svg" alt="Open OnDemand Logo" width="320" />

# Open OnDemand

**Connecting Computing Power With Powerful Minds**

_A browser-based portal that gives researchers, students, and engineers remote web access to HPC systems — no client software, no command line required._

![Latest Release](https://img.shields.io/github/release/osc/ondemand.svg?color=informational)
[![Tests](https://github.com/OSC/ondemand/actions/workflows/tests.yml/badge.svg)](https://github.com/OSC/ondemand/actions/workflows/tests.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE.md)
[![Discourse](https://img.shields.io/discourse/posts?server=https%3A%2F%2Fdiscourse.openondemand.org)](https://discourse.openondemand.org)
[![Deployments](https://img.shields.io/badge/deployments-2100%2B-brightgreen)](https://www.openondemand.org/about-us#active-deployments)
[![NSF Funded](https://img.shields.io/badge/NSF-funded-blue)](https://www.nsf.gov/)

[Website](https://www.openondemand.org) · [Documentation](https://osc.github.io/ood-documentation/) · [Discourse](https://discourse.openondemand.org) · [Community Hub](https://ondemand.connectci.org) · [Events](https://www.openondemand.org/upcoming-events)

</div>

---

## Table of Contents

- [What is Open OnDemand?](#what-is-open-ondemand)
- [Key Features](#key-features)
- [Getting Started](#getting-started)
- [License](#license)
- [Acknowledgments](#acknowledgments)

---

## What is Open OnDemand?

Open OnDemand (OOD) is an open-source, NSF-funded web portal that makes high-performance computing and resources accessible to everyone. 
Instead of requiring users to learn SSH, command-line job schedulers, or VPN clients, OOD delivers a full HPC experience through any modern browser.

It is deployed at **over 2,100 organizations worldwide** — from major research universities to national labs to technology companies — 
and is the access layer powering some of the world's most capable supercomputers.

---

## Key Features

- 🖥️ **Web-based shell** — full terminal in the browser, no SSH client needed
- 📊 **Job Composer & Monitor** — build, submit, and track batch jobs through a visual interface
- 📁 **File Manager** — upload, download, and manage HPC filesystem files from any device
- 🔬 **Interactive Apps** — launch Jupyter, RStudio, MATLAB, VS Code, and custom apps directly on compute nodes
- ⚙️ **Fully Customizable** — tailor the portal to your cluster, scheduler (Slurm, PBS, LSF, SGE), and software stack
- 🔐 **Authentication Agnostic** — integrates with Keycloak, Shibboleth, LDAP, CILogon, and more
- 🌍 **Multi-Cluster Support** — a single OOD deployment can serve multiple HPC clusters
- 📦 **Extensible App Framework** — develop and share your own Passenger apps or Batch Connect applications

---

## Getting Started

### Prerequisites

- RHEL/Rocky/AlmaLinux 8 or 9
- A supported batch scheduler (Slurm recommended)
- Root access to the web/login node

### Install

Full installation documentation is available at **[osc.github.io/ood-documentation](https://osc.github.io/ood-documentation/)**.

```bash
# Add the OOD repository (RHEL/Rocky 9 example)
sudo dnf install -y https://yum.osc.edu/ondemand/4.1/ondemand-release-web-4.1-1.el9.noarch.rpm

# Install Open OnDemand
sudo dnf install -y ondemand

# Follow the post-install configuration guide:
# https://osc.github.io/ood-documentation/latest/installation/
```

### Test Drive

Not ready to install? You can **[test drive Open OnDemand](https://www.openondemand.org/administer-open-ondemand#test-drive-ood)** on our demo instance before deploying it at your site.

---

## License

Open OnDemand is released under the **MIT License**. See [LICENSE.md](LICENSE.md) for details.

---

## Acknowledgments

<div align="center">

This material is based upon work supported by the **National Science Foundation** under grant numbers
[1534949](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1534949),
[1835725](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1835725),
[2138286](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2138286),
[2303692](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2303692), and
[2411375](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2411375).

<br>

Open OnDemand is developed and maintained by the
[Ohio Supercomputer Center (OSC)](https://www.osc.edu)
in partnership with the global OOD community.

</div>
