#!/bin/bash
echo "Running in travis: ${TRAVIS}"

runuser -u ${DEFAULT_USER} -- ${PACMAN} -Syu --noconfirm
runuser -u ${DEFAULT_USER} -- ${PACMAN} -S jq kittypack --asdeps --noconfirm

# https://docs.xfce.org/xfce/building

# These are packages which have a -git version on AUR, which is good because
# we need to build XFCE from git
AUR_GIT_PACKAGES=(
    xfce4-dev-tools libxfce4util xfconf libxfce4ui garcon exo
    xfce4-panel thunar thunar-volman xfce4-power-manager
    xfce4-settings xfce4-session xfdesktop xfwm4 xfce4-appfinder
    tumbler xfce4-vala xfce-theme-greybird xfce4-panel-profiles

    # apps
    mousepad parole xfburn xfce4-notifyd xfce4-screensaver
    xfce4-screenshooter xfce4-taskmanager xfce4-terminal
    xfce4-volumed-pulse xfmpc gigolo

    # panel plugins
    xfce4-clipman-plugin xfce4-cpufreq-plugin xfce4-datetime-plugin
    xfce4-diskperf-plugin xfce4-fsguard-plugin xfce4-genmon-plugin
    xfce4-netload-plugin xfce4-pulseaudio-plugin xfce4-smartbookmark-plugin
    xfce4-systemload-plugin xfce4-weather-plugin xfce4-xkb-plugin
)

# These are packages which we are able find in the main repos
# Most of these do not build directly from source, but still nice to have
ARCH_MAIN_PACKAGES=(
    # apps
    catfish ristretto xfce4-dict

    # panel plugins
    xfce4-mpc-plugin xfce4-calculator-plugin xfce4-wavelan-plugin
    xfce4-mailwatch-plugin xfce4-notes-plugin xfce4-cpugraph-plugin
    xfce4-battery-plugin xfce4-timer-plugin xfce4-verve-plugin
    xfce4-sensors-plugin xfce4-whiskermenu-plugin thunar-archive-plugin
    thunar-media-tags-plugin
)

# These are packages we can find on AUR (better than nothing)
AUR_PACKAGES=(
    xfce4_mixer xfce4-statusnotifier-plugin xfce4-indicator-plugin
    xfce4-places-plugin elementary-xfce-icons
)

# all packages to be built: 63
ALL_XFCE_PACKAGES=(
    ${AUR_GIT_PACKAGES[@]} ${ARCH_MAIN_PACKAGES[@]}
    ${AUR_PACKAGES[@]}
)

# called to fetch the dependencies
function fetch_deps_rpc() {
    # https://wiki.archlinux.org/index.php/Aurweb_RPC_interface#API_usage
    AUR_RPC='https://aur.archlinux.org/rpc/?v=5'
    mapfile -t git_deps < <(
        curl --silent "$AUR_RPC&type=info&by=name$(printf '&arg[]=%s-git' ${AUR_GIT_PACKAGES[@]})" \
        | jq -r '.results | ([.[].Depends?], [.[].MakeDepends?]) | flatten | join(" ")'
    )

    mapfile -t aur_deps < <(
        curl --silent "$AUR_RPC&type=info&by=name$(printf '&arg[]=%s' ${AUR_PACKAGES[@]})" \
        | jq -r '.results | ([.[].Depends?], [.[].MakeDepends?]) | flatten | join(" ")'
    )

    # ARCH_WEB='https://archlinux.org/packages/search/json/'
    mapfile -t web_deps < <(
        for arch_pkg in ${ARCH_MAIN_PACKAGES[@]}; do
            kittypack --json "$arch_pkg" | jq -c '.results'
        done | jq -csr 'flatten | ([.[].depends?], [.[].makedepends?]) | flatten | join(" ")'
    )

    # Build/runtime dependencies
    DEPS=( $(printf '%s\n' ${git_deps[0]} ${aur_deps[0]} ${web_deps[0]} | sort -u) )
    # Mostly build dependencies
    MAKE_DEPS=( $(printf '%s\n' ${git_deps[1]} ${aur_deps[0]} ${web_deps[1]} | sort -u) )
}

# TODO: Finish the steps required to automate this process
# The steps are:
# 1. Remove all duplicates from both DEPS and MAKE_DEPS (keep only least restrictive in terms of version)
# 2. Remove all values from both DEPS and MAKE_DEPS which are also in ALL_XFCE_PACKAGES
# 3. Remove everything from MAKE_DEPS which is also in DEPS (Not really necessary)
# Some offline work involving the above function and some python and we have...

DEPS=(
    adwaita-icon-theme alsa-lib>=1.2.1 colord dbus-glib desktop-file-utils
    file gdk-pixbuf2 glib2 gnome-themes-extra gnutls gst-plugins-base
    gst-plugins-base-libs gst-plugins-good gtk-doc gtk-engine-murrine
    gtk2 gtk3 gtksourceview3 hicolor-icon-theme ido intltool libburn
    libdbusmenu-gtk3 libexif libgtop libgudev libindicator-gtk2 libindicator-gtk3
    libisofs libkeybinder3 libmpd libnotify libpng libpulse librsvg libsm libsoup
    libunique libwnck3 libxklavier libxml2 libxpresent libxss libxtst lm_sensors
    make pkg-config polkit polkit-gnome pulseaudio python-cairo python-dbus
    python-gobject python-pexpect python-ptyprocess python-xdg qrencode
    startup-notification taglib upower vte3>=0.38 xdg-utils xorg-iceauth
    xorg-xinit xorg-xrdb
)

MAKE_DEPS=(
    autoconf chrpath cmake ffmpegthumbnailer freetype2 git glade glib-perl
    gobject-introspection hddtemp libgepub libgsf libopenraw libtool libxslt
    meson netcat ninja optipng perl-extutils-depends perl-extutils-pkgconfig
    perl-uri pkgconfig poppler-glib python python-distutils-extra sassc systemd vala
)

if [ "${TRAVIS,,}" = false ]; then
#   https://github.com/moby/moby/issues/31243
  runuser -u ${DEFAULT_USER} -- ${PACMAN} -S ${DEPS[@]} --noconfirm --needed
  runuser -u ${DEFAULT_USER} -- ${PACMAN} -S --asdeps ${MAKE_DEPS[@]} --noconfirm --needed
else
  echo Filtered package output to save output log size
  PIPE=/dev/null

  printf "Installing: %s %s %s %s %s\n" "${DEPS[@]}"
  runuser -u ${DEFAULT_USER} -- ${PACMAN} -S ${DEPS[@]} --noconfirm --needed >$PIPE

  printf "Installing: %s %s %s %s %s\n" "${MAKE_DEPS[@]}"
  runuser -u ${DEFAULT_USER} -- ${PACMAN} -S --asdeps ${MAKE_DEPS[@]} --noconfirm --needed >$PIPE
fi
