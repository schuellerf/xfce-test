#!/usr/bin/bash
echo "Running in travis: ${TRAVIS}"

set +xe
sudo apt-get update

PACKAGES=""

PACKAGES+=" gnome-themes-standard libglib2.0-bin build-essential libgtk-3-dev gtk-doc-tools libgtk2.0-dev libx11-dev libglib2.0-dev libwnck-3-dev intltool libdbus-glib-1-dev liburi-perl x11-xserver-utils libvte-2.91-dev dbus-x11 strace libgl1-mesa-dev adwaita-icon-theme libwnck-dev adwaita-icon-theme-full cmake libsoup2.4-dev libpcre2-dev exo-utils libgtksourceview-3.0-dev libtag1-dev libtool"

PACKAGES+=" libgstreamer1.0-0 gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-doc gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-gtk3 gstreamer1.0-qt5 gstreamer1.0-pulseaudio"

PACKAGES+=" python3-distutils-extra python3-httplib2"
PACKAGES+=" libxss-dev"
PACKAGES+=" libindicator3-dev"
PACKAGES+=" libxmu-dev"
PACKAGES+=" libburn-dev libisofs-dev"
PACKAGES+=" libpulse-dev libkeybinder-3.0-dev"
PACKAGES+=" libmpd-dev valac gobject-introspection libgirepository1.0-dev"
PACKAGES+=" libvala-0.48-dev librsvg2-dev libtagc0-dev"
PACKAGES+=" libdbusmenu-gtk3-dev"
PACKAGES+=" libgtop2-dev"
PACKAGES+=" libpython3.8-dev"

# Greybird
PACKAGES+=" autoconf libgdk-pixbuf2.0-dev libglib2.0-bin librsvg2-dev meson ruby-sass sassc"

# at least: for xfce4-power-manager, xfce4-settings, xfdesktop, xfce4-notifyd, xfce4-volumed-pulse, xfce4-pulseaudio-plugin, xfce4-places-plugin, xfce4-sensors-plugin
PACKAGES+=" libnotify-dev"

# for xfce4-power-manager
PACKAGES+=" libupower-glib-dev"

# for catfish:
PACKAGES+=" python-distutils-extra"

# for ristretto
PACKAGES+=" libexif-dev"

# for xfce4-vala
PACKAGES+=" libvala-0.48-dev"

# for xfce4-screensaver, xfce4-xkb-plugin
PACKAGES+=" libxklavier-dev"

# for xfce4-mixer
PACKAGES+=" libgstreamer-plugins-base1.0-dev"

# for parole
PACKAGES+=" libgstreamer1.0-dev"

# for  xfce4-mailwatch-plugin
PACKAGES+=" libgcrypt20-dev"


# Test specific
# python-wheel is a missing dependency from behave
# psmisc for "killall"
PACKAGES+=" psmisc ffmpeg x11-utils libxrandr-dev"
PACKAGES+=" python3-pip python3-dogtail python3-psutil gdb valgrind tmuxinator tmux ltrace"

if [ "$TRAVIS" == "FALSE" ]; then
  PIPE=/dev/stdout
  sudo apt-get -y --no-install-recommends install $PACKAGES >$PIPE
else
  echo Filtered package output to save output log size
  PIPE=/dev/null
  # Doing the loop for travis
  # 1. avoid too much log output
  # 2. avoid timeout
  for p in $PACKAGES; do

      echo "Installing $p"
      sudo apt-get -y --no-install-recommends install $p >$PIPE
  done
fi
sudo apt-get -y remove libxfce4ui-1-0 libxfce4ui-2-0
sudo rm -rf /var/lib/apt/lists/*
