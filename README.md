# Batch Connect - Desktop

![GitHub Release](https://img.shields.io/github/release/osc/bc_desktop.svg)
[![GitHub License](https://img.shields.io/badge/license-MIT-green.svg)](https://opensource.org/licenses/MIT)

A Batch Connect app designed to launch a GUI desktop withing a batch job.

## Prerequisites

This Batch Connect app requires the following software be installed on the
**compute nodes** that the batch job is intended to run on (**NOT** the
OnDemand node).

One of the following desktops:

- [Xfce Desktop] 4+
- [Mate Desktop] 1+ (*default*)
- [Gnome Desktop] 2 (currently we do not support Gnome 3)

For VNC server support:

- [TurboVNC] 2.1+
- [websockify] 0.8.0+

For hardware rendering support:

- [X server]
- [VirtualGL] 2.3+

[Xfce Desktop]: https://xfce.org/
[Mate Desktop]: https://mate-desktop.org/
[Gnome Desktop]: https://www.gnome.org/
[TurboVNC]: http://www.turbovnc.org/
[websockify]: https://github.com/novnc/websockify
[X server]: https://www.x.org/
[VirtualGL]: http://www.virtualgl.org/

## Install

Use git to clone this app and checkout the desired branch/version you want to
use:

```sh
scl enable git19 -- git clone <repo>
cd <dir>
scl enable git19 -- git checkout <tag/branch>
```

You will not need to do anything beyond this as all necessary assets are
installed. You will also not need to restart this app as it isn't a Passenger
app.

To update the app you would:

```sh
cd <dir>
scl enable git19 -- git fetch
scl enable git19 -- git checkout <tag/branch>
```

Again, you do not need to restart the app as it isn't a Passenger app.

## Configuration

Please see the [Install Desktops] section in the [Open OnDemand Documentation]
to learn more about setting up and configuring a desktop at your HPC center.

[Install Desktops]: https://osc.github.io/ood-documentation/master/enable-desktops.html
[Open OnDemand Documentation]: https://osc.github.io/ood-documentation/master/index.html

## Contributing

1. Fork it ( https://github.com/OSC/bc_desktop/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
