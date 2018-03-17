# Remove any preconfigured monitors
if [[ -f "${HOME}/.config/monitors.xml" ]]; then
  mv "${HOME}/.config/monitors.xml" "${HOME}/.config/monitors.xml.bak"
fi

# Copy over default panel if doesn't exist, otherwise it will prompt the user
XFCE_CONFIG_ROOT="${HOME}/.config/xfce4/xfconf/xfce-perchannel-xml"
if [[ ! -e "${XFCE_CONFIG_ROOT}/xfce4-panel.xml" ]]; then
  mkdir -p "${XFCE_CONFIG_ROOT}"
  cp "/etc/xdg/xfce4/panel/default.xml" "${XFCE_CONFIG_ROOT}/xfce4-panel.xml"
fi

# Disable useless services on autostart
AUTOSTART="${HOME}/.config/autostart"
mkdir -p "${AUTOSTART}"
for service in "pulseaudio" "rhsm-icon" "spice-vdagent" "tracker-extract" "tracker-miner-apps" "tracker-miner-user-guides" "xfce4-power-manager" "xfce-polkit"; do
  echo -e "[Desktop Entry]\nHidden=true" > "${AUTOSTART}/${service}.desktop"
done

# Start up xfce desktop (block until user logs out of desktop)
xfce4-session
