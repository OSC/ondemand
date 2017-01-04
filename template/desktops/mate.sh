#!/bin/bash -l

# Turn off screensaver (this may not exist at all)
gsettings set org.mate.screensaver idle-activation-enabled false

# Remove any preconfigured monitors
if [[ -f "${HOME}/.config/monitors.xml" ]]; then
  mv "${HOME}/.config/monitors.xml" "${HOME}/.config/monitors.xml.bak"
fi

# Export the module function for the mate session
[[ $(type -t module) == "function" ]] && export -f module

# Start up mate desktop (block until user logs out of desktop)
mate-session
