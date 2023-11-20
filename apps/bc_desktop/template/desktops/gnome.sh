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

# gnome won't start correctly without DBUS_SESSION_BUS_ADDRESS set.
eval $(dbus-launch --sh-syntax)

source /etc/os-release

function classic(){
  export XDG_SESSION_TYPE="${XDG_SESSION_TYPE:-x11}"
  export GNOME_SHELL_SESSION_MODE="${GNOME_SHELL_SESSION_MODE:-classic}"
  export GNOME_SESSION_MODE="${GNOME_SESSION_MODE:-classic}"
}

function wayland() {
  export XDG_SESSION_TYPE="${XDG_SESSION_TYPE:-x11}"
  export GNOME_SHELL_SESSION_MODE="${GNOME_SHELL_SESSION_MODE:-wayland}"
  export GNOME_SESSION_MODE="${GNOME_SESSION_MODE:-wayland}"
}

if [[ "$ID_LIKE" =~ "fedora" ]]; then
  if [[ "$VERSION_ID" < "8.0" ]]; then
    # el7 will crash using wayland.
    classic
  else
    wayland
  fi
else
  wayland
fi

# Start up Gnome desktop (block until user logs out of desktop)
/etc/X11/xinit/Xsession gnome-session
