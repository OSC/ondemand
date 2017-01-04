#!/bin/bash -l

# Turn off screensaver
gconftool-2 --set -t boolean /apps/gnome-screensaver/idle_activation_enabled false

# Use browser window instead in nautilus
gconftool-2 --set -t boolean /apps/nautilus/preferences/always_use_browser true

# Remove any preconfigured monitors
if [[ -f "${HOME}/.config/monitors.xml" ]]; then
  mv "${HOME}/.config/monitors.xml" "${HOME}/.config/monitors.xml.bak"
fi

# Export the module function for the Gnome session
[[ $(type -t module) == "function" ]] && export -f module

# Start up Gnome desktop (block until user logs out of desktop)
/etc/X11/xinit/Xsession gnome-session
