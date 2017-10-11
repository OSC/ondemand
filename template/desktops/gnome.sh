# Turn off screensaver
gconftool-2 --set -t boolean /apps/gnome-screensaver/idle_activation_enabled false

# Use browser window instead in nautilus
gconftool-2 --set -t boolean /apps/nautilus/preferences/always_use_browser true

# Disable the disk check utility on autostart
mkdir -p "${HOME}/.config/autostart"
cat "/etc/xdg/autostart/gdu-notification-daemon.desktop" <(echo "X-GNOME-Autostart-enabled=false") > "${HOME}/.config/autostart/gdu-notification-daemon.desktop"

# Remove any preconfigured monitors
if [[ -f "${HOME}/.config/monitors.xml" ]]; then
  mv "${HOME}/.config/monitors.xml" "${HOME}/.config/monitors.xml.bak"
fi

# Start up Gnome desktop (block until user logs out of desktop)
/etc/X11/xinit/Xsession gnome-session
