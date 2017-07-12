# Batch Connect - Desktop

![GitHub Release](https://img.shields.io/github/release/osc/bc_desktop.svg)
![GitHub License](https://img.shields.io/github/license/osc/bc_desktop.svg)

A Batch Connect app designed to launch a GUI desktop withing a batch job.

## Prerequisites

This app requires the following software be installed on the nodes that the
batch job is intended to run on.

One of the following desktops:

- [Mate Desktop](https://mate-desktop.org/) 1+ (*default*)
- [Gnome](https://www.gnome.org/) 2 (currently we do not support Gnome 3)

For VNC server support:

- [TurboVNC](http://www.turbovnc.org/) 2.1+
- [websockify](https://github.com/novnc/websockify) 0.8.0+

For hardware rendering support:

- [X server](https://www.x.org/)
- [VirtualGL](http://www.virtualgl.org/) 2.3+

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

> **Note**
>
> In some cases you may have site specific configuration files under the
> directory `local.OOD_SITE/` (see `local.osc/`). You can and should install
> these every time you install or update the application with:
>
> ```sh
> OOD_SITE=osc scl enable rh-ruby22 -- bin/setup
> ```

## Template Specification

### DESKTOP

This environment variable describes the desktop to load (e.g., `gnome`, `mate`,
...). It will run the corresponding script that can be found in
[template/desktops](template/desktops).

By default the Mate desktop is used when a Desktop session is launched.

## Contributing

1. Fork it ( https://github.com/OSC/bc_desktop/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
