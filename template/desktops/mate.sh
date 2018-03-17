# Turn off screensaver (this may not exist at all)
gsettings set org.mate.screensaver idle-activation-enabled false

# Remove any preconfigured monitors
if [[ -f "${HOME}/.config/monitors.xml" ]]; then
  mv "${HOME}/.config/monitors.xml" "${HOME}/.config/monitors.xml.bak"
fi

# Disable useless services on autostart
AUTOSTART="${HOME}/.config/autostart"
mkdir -p "${AUTOSTART}"
for service in "gnome-keyring-gpg" "gnome-keyring-pkcs11" "gnome-keyring-secrets" "gnome-keyring-ssh" "mate-volume-control-applet" "polkit-mate-authentication-agent-1" "pulseaudio" "rhsm-icon" "spice-vdagent" "xfce4-power-manager"; do
  cat "/etc/xdg/autostart/${service}.desktop" <(echo "X-MATE-Autostart-enabled=false") > "${AUTOSTART}/${service}.desktop"
done

# Run Mate Terminal as login shell (sets proper TERM)
dconf write /org/mate/terminal/profiles/default/login-shell true

# Start up mate desktop (block until user logs out of desktop)
mate-session
