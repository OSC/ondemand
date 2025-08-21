# Open OnDemand
![GitHub Release](https://img.shields.io/github/release/osc/ondemand.svg?color=informational)
[![Build Status](https://github.com/osc/ondemand/workflows/Tests/badge.svg)](https://github.com/OSC/ondemand/actions?query=workflow%3ATests)
[![GitHub License](https://img.shields.io/badge/license-MIT-green.svg?color=success)](https://opensource.org/licenses/MIT)
[![Paper DOI](http://joss.theoj.org/papers/10.21105/joss.00622/status.svg)](https://doi.org/10.21105/joss.00622)
[![Source DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.6323791.svg)](https://doi.org/10.5281/zenodo.6323791)
> Supercomputing. Seamlessly. Open, Interactive HPC Via the Web


- Website: https://openondemand.org/
- Website repo: https://github.com/OSC/openondemand.org
- Documentation: https://osc.github.io/ood-documentation/latest/
- Main code repo: https://github.com/OSC/ondemand
- Core library repo: https://github.com/OSC/ood_core
- Slack: [Open OnDemand Slack]
- Discourse: [Discourse]

This work is supported by the National Science Foundation of the United States under the award [NSF SI2-SSE-1534949](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1534949) and [NSF CSSI-Frameworks-1835725](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1835725).

## Overview
Open OnDemand is an NSF-funded open-source HPC portal. The goal of Open OnDemand is to provide an easy way for system administrators to provide web access to their HPC resources, including, but not limited to:

* Plugin-free web experience
* Easy file management
* Command-line shell access
* Job management and monitoring across different batch servers and resource managers
* Graphical desktop environments and desktop applications

## Demo

![Open ondemand demo demonstrating integration with Open XDMOD; interactive jobs with desktops, Jupyter and visual studio code; file browsing, creation, editing and deletion.](docs/imgs/open_ondemand_demo.gif)

## Installation
Installing Open OnDemand is simple, use our `.rpm` or `.deb` packages. Get started by visiting the [installation instructions] in our documentation.

### Container demos

You can use the [hpc toolset tutorial] to demonstrate Open OnDemand before installing on your systems. This `docker-compose` project
has a full suite of applications like Slurm, Coldfront and of course Open OnDemand.  It also includes tutorials on how to use
and update the applications.

## Architecture
Learn more about Open OnDemand's system architecture and request lifecycle by visiting our <a href="https://osc.github.io/ood-documentation/latest/architecture.html">documentation</a>.

## Community
Open OnDemand has an active and growing community! Don't hesitate to reach out to the developers via our [Discourse] instance if you would like more information or need help installing or configuring Open OnDemand.
<br/>
<br/>
<a href="https://discourse.osc.edu"><img src="https://upload.wikimedia.org/wikipedia/commons/1/17/Discourse_icon.svg" width=150></a>

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/OSC/ondemand. Please read our [contributing guide] to get started, or find us on our [Discourse] instance if you have any questions about contributing!

## License

The code is available as open source under the terms of the [MIT License].

## Maintained by OSC
This project is maintained by the <a href="https://www.osc.edu">Ohio Supercomputer Center (OSC)</a>, a member of the <a href="https://www.oh-tech.org/">Ohio Technology Consortium</a>, the technology and information division of the <a href="https://education.ohio.gov/">Ohio Department of Higher Education.</a>

[MIT License]: http://opensource.org/licenses/MIT
[Open OnDemand Documentation]: https://osc.github.io/ood-documentation/latest/
[installation instructions]: https://osc.github.io/ood-documentation/latest/requirements.html
[contributing guide]: CONTRIBUTING.md
[Discourse]: https://discourse.osc.edu
[hpc toolset tutorial]: https://github.com/ubccr/hpc-toolset-tutorial/
[Open OnDemand Slack]: http://openondemand.org/slack
