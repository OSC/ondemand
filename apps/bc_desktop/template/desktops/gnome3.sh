# gnome won't start correctly without DBUS_SESSION_BUS_ADDRESS set.
eval $(dbus-launch --sh-syntax)

gnome-session
