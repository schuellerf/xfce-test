#!/usr/bin/bash

PIPE=$(mktemp -u)
mkfifo $PIPE
( 
set +xe
sudo apt-get update

sudo apt-get -y --no-install-recommends install gnome-themes-standard libglib2.0-bin build-essential libgtk-3-dev gtk-doc-tools libgtk2.0-dev libx11-dev libglib2.0-dev libwnck-3-dev intltool libdbus-glib-1-dev liburi-perl x11-xserver-utils libvte-2.91-dev dbus-x11 strace libgl1-mesa-dev adwaita-icon-theme libwnck-dev adwaita-icon-theme-full cmake libsoup2.4-dev libpcre2-dev exo-utils libgtksourceview-3.0-dev libtag1-dev

sudo apt-get -y --no-install-recommends install libgstreamer1.0-0 gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-doc gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-gtk3 gstreamer1.0-qt5 gstreamer1.0-pulseaudio

sudo apt-get -y --no-install-recommends build-dep xfce4-panel thunar xfce4-settings xfce4-session xfdesktop4 xfwm4 xfce4-appfinder tumbler xfce4-terminal xfce4-clipman-plugin xfce4-screenshooter 
sudo apt-get -y --no-install-recommends install xfce4-pulseaudio-plugin xfce4-statusnotifier-plugin
sudo apt-get -y --no-install-recommends install python-distutils-extra python3-httplib2
sudo apt-get -y --no-install-recommends install libxss-dev
sudo apt-get -y --no-install-recommends install libindicator3-dev
sudo apt-get -y --no-install-recommends install libxmu-dev
sudo apt-get -y --no-install-recommends install libburn-dev libisofs-dev
sudo apt-get -y --no-install-recommends install libpulse-dev libkeybinder-3.0-dev
sudo apt-get -y --no-install-recommends install libmpd-dev valac gobject-introspection libgirepository1.0-dev
sudo apt-get -y --no-install-recommends install libvala-0.48-dev librsvg2-dev libtagc0-dev
sudo apt-get -y --no-install-recommends install libdbusmenu-gtk3-dev
sudo apt-get -y --no-install-recommends install libgtop2-dev
sudo apt-get -y --no-install-recommends install libpython3.8-dev
sudo apt-get -y remove libxfce4ui-1-0 libxfce4ui-2-0
sudo rm -rf /var/lib/apt/lists/*
) >$PIPE &

echo "Running in travis: ${TRAVIS}"
if [ "$TRAVIS" == "FALSE" ]; then
  cat <$PIPE
else
  echo Filtered package output to save output log size
  cat <$PIPE >/dev/null
fi
