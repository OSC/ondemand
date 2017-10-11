# Turn off screensaver (this may not exist at all)
gsettings set org.mate.screensaver idle-activation-enabled false

# Remove any preconfigured monitors
if [[ -f "${HOME}/.config/monitors.xml" ]]; then
  mv "${HOME}/.config/monitors.xml" "${HOME}/.config/monitors.xml.bak"
fi

# Start up mate desktop (block until user logs out of desktop)
mate-session
