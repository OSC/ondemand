# Batch Connect - Desktop

![GitHub Release](https://img.shields.io/github/release/osc/bc_desktop.svg)
![GitHub License](https://img.shields.io/github/license/osc/bc_desktop.svg)

A library used for launching a GUI Desktop within a batch job. It is designed to:

  - carry over as much of the environment set in the batch job to the desktop
    environment (e.g., `LD_LIBRARY_PATH`, Bash functions, ...)
  - run as much of the corresponding code underneath the parent process of the
    batch job (i.e., avoid daemonizing processes)
  - clean up the VNC server started when the user logs out of the desktop

## Bower Install

You can install this in any project using Bower:

```sh
bower install git://github.com/OSC/bc_desktop.git --save
```

## Specification

### ROOT

All assets in this package look for dependencies in the specified `$ROOT`
directory. This should be set to correspond to the included `template/`
directory.

An example running the `xstartup` script included in this package:

```sh
# Path where you installed this project
BC_DESKTOP_DIR="/path/to/bc_desktop/template"

# Run the bc_desktop `xstartup` script with proper `$ROOT` set
ROOT="${BC_DESKTOP_DIR}" ${BC_DESKTOP_DIR}/xstartup
```

## DESKTOP

*Optional* (Default: `gnome`)

This environment variable describes the desktop to load (e.g., `gnome`, `mate`,
...). It will run the corresponding script that can be found in
[template/desktops](template/desktops).

## Usage

This will launch a Gnome desktop without hardware rendering support. Features
set on the Gnome desktop include:

  - disabling the screen saver
  - setting Nautilus to browser window mode
  - disabling any pre-configured `monitors.xml`
  - exporting the `module` function for
    [Lmod](https://www.tacc.utexas.edu/research-development/tacc-projects/lmod)
    support in any terminals launched within the desktop

## Contributing

1. Fork it ( https://github.com/OSC/bc_desktop/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
