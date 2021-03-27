#!/bin/bash
echo "Running in travis: ${TRAVIS}"

runuser -u ${DEFAULT_USER} -- ${PACMAN} -Syu --noconfirm
runuser -u ${DEFAULT_USER} -- ${PACMAN} -S jq kittypack --asdeps --noconfirm

# https://docs.xfce.org/xfce/building

# templates are used to generate a final PKGBUILD for each package
BASE_TEMPLATE="$(cat <<EOF
# Maintainer: Chigozirim Chukwu <noblechuk5[at]web[dot]de>

pkgname='\${name}'
pkgver=1.0
pkgrel=1
pkgdesc='\${description}'
arch=(any)
url='\${url}'
license=(\${license:-GPLv2})
groups=(xfce-test)
depends=(\${depends[@]})
makedepends=(\${makedepends[@]})
optdepends=(\${optdepends[@]})
provides=(\\\$pkgname)
conflicts=(\\\$pkgname)
options=(\${options[@]})
source=("\\\$pkgname::git+\\\$url.git#branch=${MAIN_BRANCH}")
md5sums=('SKIP')

pkgver() {
  cd "\\\$pkgname"
  git describe --long --tags | sed -E "s:^\\\$pkgname.::;s/^v//;s/^xfce-//;s/([^-]*-g)/r\1/;s/-/./g"
}

prepare() {
  cd "\\\$pkgname"
  if [ -n '${DOWNLOAD_DATE}' ]; then
    commit_sha="\\\$(git rev-list -1 --before='${DOWNLOAD_DATE}' --abbrev-commit --abbrev=14 HEAD)"
    if [ -n \\\$commit_sha ]; then
      git checkout --quiet \\\$commit_sha
    else
      echo "Can't switch to specific date '$DOWNLOAD_DATE' - leaving as is on '$MAIN_BRANCH'"
    fi
  fi
}
EOF
)"

# Mostly taken from: https://wiki.archlinux.org/index.php/Arch_package_guidelines
AUTOGEN_TEMPLATE="$(cat <<EOF
$BASE_TEMPLATE

build() {
  cd "\\\$pkgname"
  ./autogen.sh $AUTOGEN_OPTIONS
  make
}

package() {
  cd "\\\$pkgname"
  make DESTDIR="\\\${pkgdir}" install
}
EOF
)"

MAKE_TEMPLATE="$(cat <<EOF
$BASE_TEMPLATE

build() {
  cd "\\\$pkgname"
  ./configure $AUTOGEN_OPTIONS
  make
}

package() {
  cd "\\\$pkgname"
  make DESTDIR="\\\${pkgdir}" install
}
EOF
)"

PYTHON_TEMPLATE="$(cat <<EOF
$BASE_TEMPLATE

build() {
  cd "\\\$pkgname"
  python setup.py build
}

package() {
  cd "\\\$pkgname"
  python setup.py install --root="\\\$pkgdir" --optimize=1
}
EOF
)"

CMAKE_TEMPLATE="$(cat <<EOF
$BASE_TEMPLATE

build() {
  cmake -B build -S "\\\$pkgname" \
    -DCMAKE_BUILD_TYPE='None' \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_INSTALL_LIBDIR=lib
  make -C build
}

package() {
  cd "\\\$pkgname"
  make DESTDIR="\\\${pkgdir}" install
}
EOF
)"

MESON_TEMPLATE="$(cat <<EOF
$BASE_TEMPLATE

build() {
  arch-meson source build
  meson compile -C build
}

package() {
  DESTDIR="\\\$pkgdir" meson install -C build
}
EOF
)"

xfce_url="https://gitlab.xfce.org/"

# syntax for the packages:
# description||url||license||depends||makedepends||optdepends||options||template

# These are packages which have a -git version on AUR, which is good because
# we need to build XFCE from git
declare -A AUR_GIT_PACKAGES=(
    [exo]="''||'$xfce_url/xfce/exo'||''||''||''||''||''||AUTOGEN_TEMPLATE"
    [garcon]="''||'$xfce_url/xfce/garcon'||''||''||''||''||''||AUTOGEN_TEMPLATE"
    [libxfce4ui]="''||'$xfce_url/xfce/libxfce4ui'||''||''||''||''||''||AUTOGEN_TEMPLATE"
    [libxfce4util]="''||'$xfce_url/xfce/libxfce4util'||''||''||''||''||''||AUTOGEN_TEMPLATE"
    [thunar]="''||'$xfce_url/xfce/thunar'||''||''||''||''||''||AUTOGEN_TEMPLATE"
    [thunar-volman]="''||'$xfce_url/xfce/thunar-volman'||''||''||''||''||''||AUTOGEN_TEMPLATE"
    [tumbler]="''||'$xfce_url/xfce/tumbler'||''||''||''||''||''||AUTOGEN_TEMPLATE"
    [xfce4-appfinder]="''||'$xfce_url/xfce/xfce4-appfinder'||''||''||''||''||''||AUTOGEN_TEMPLATE"
    [xfce4-dev-tools]="''||'$xfce_url/xfce/xfce4-dev-tools'||''||''||''||''||''||AUTOGEN_TEMPLATE"
    [xfce4-panel]="''||'$xfce_url/xfce/xfce4-panel'||''||''||''||''||''||AUTOGEN_TEMPLATE"
    [xfce4-power-manager]="''||'$xfce_url/xfce/xfce4-power-manager'||''||''||''||''||''||AUTOGEN_TEMPLATE"
    [xfce4-session]="''||'$xfce_url/xfce/xfce4-session'||''||''||''||''||''||AUTOGEN_TEMPLATE"
    [xfce4-settings]="''||'$xfce_url/xfce/xfce4-settings'||''||''||''||''||''||AUTOGEN_TEMPLATE"
    [xfconf]="''||'$xfce_url/xfce/xfconf'||''||''||''||''||''||AUTOGEN_TEMPLATE"
    [xfdesktop]="''||'$xfce_url/xfce/xfdesktop'||''||''||''||''||''||AUTOGEN_TEMPLATE"
    [xfwm4]="''||'$xfce_url/xfce/xfwm4'||''||''||''||''||''||AUTOGEN_TEMPLATE"

    [elementary-xfce-icons]="''||'https://github.com/shimmerproject/elementary-xfce'||''||''||''||''||''||MAKE_TEMPLATE"
    [xfce-theme-greybird]="''||'https://github.com/shimmerproject/Greybird'||''||''||''||''||''||MESON_TEMPLATE"

    # bindings
    [xfce4-vala]="''||'$xfce_url/bindings/xfce4-vala'||''||''||''||''||''||AUTOGEN_TEMPLATE"

    # apps
    [gigolo]="''||'$xfce_url/apps/gigolo'||''||''||''||''||''||AUTOGEN_TEMPLATE"
    [mousepad]="''||'$xfce_url/apps/mousepad'||''||''||''||''||''||AUTOGEN_TEMPLATE"
    [parole]="''||'$xfce_url/apps/parole'||''||''||''||''||''||AUTOGEN_TEMPLATE"
    [xfburn]="''||'$xfce_url/apps/xfburn'||''||''||''||''||''||AUTOGEN_TEMPLATE"
    [xfce4-notifyd]="''||'$xfce_url/apps/xfce4-notifyd'||''||''||''||''||''||AUTOGEN_TEMPLATE"
    [xfce4-panel-profiles]="''||'$xfce_url/apps/xfce4-panel-profiles'||''||''||''||''||''||MAKE_TEMPLATE"
    [xfce4-screensaver]="''||'$xfce_url/apps/xfce4-screensaver'||''||''||''||''||''||AUTOGEN_TEMPLATE"
    [xfce4-screenshooter]="''||'$xfce_url/apps/xfce4-screenshooter'||''||''||''||''||''||AUTOGEN_TEMPLATE"
    [xfce4-taskmanager]="''||'$xfce_url/apps/xfce4-taskmanager'||''||''||''||''||''||AUTOGEN_TEMPLATE"
    [xfce4-terminal]="''||'$xfce_url/apps/xfce4-terminal'||''||''||''||''||''||AUTOGEN_TEMPLATE"
    [xfce4-volumed-pulse]="''||'$xfce_url/apps/xfce4-volumed-pulse'||''||''||''||''||''||AUTOGEN_TEMPLATE"
    [xfmpc]="''||'$xfce_url/apps/xfmpc'||''||''||''||''||''||AUTOGEN_TEMPLATE"

    # panel plugins
    [xfce4-clipman-plugin]="''||'$xfce_url/panel-plugins/xfce4-clipman-plugin'||''||''||''||''||''||AUTOGEN_TEMPLATE"
    [xfce4-cpufreq-plugin]="''||'$xfce_url/panel-plugins/xfce4-cpufreq-plugin'||''||''||''||''||''||AUTOGEN_TEMPLATE"
    [xfce4-datetime-plugin]="''||'$xfce_url/panel-plugins/xfce4-datetime-plugin'||''||''||''||''||''||AUTOGEN_TEMPLATE"
    [xfce4-diskperf-plugin]="''||'$xfce_url/panel-plugins/xfce4-diskperf-plugin'||''||''||''||''||''||AUTOGEN_TEMPLATE"
    [xfce4-fsguard-plugin]="''||'$xfce_url/panel-plugins/xfce4-fsguard-plugin'||''||''||''||''||''||AUTOGEN_TEMPLATE"
    [xfce4-genmon-plugin]="''||'$xfce_url/panel-plugins/xfce4-genmon-plugin'||''||''||''||''||''||AUTOGEN_TEMPLATE"
    [xfce4-netload-plugin]="''||'$xfce_url/panel-plugins/xfce4-netload-plugin'||''||''||''||''||''||AUTOGEN_TEMPLATE"
    [xfce4-pulseaudio-plugin]="''||'$xfce_url/panel-plugins/xfce4-pulseaudio-plugin'||''||''||''||''||''||AUTOGEN_TEMPLATE"
    [xfce4-smartbookmark-plugin]="''||'$xfce_url/panel-plugins/xfce4-smartbookmark-plugin'||''||''||''||''||''||AUTOGEN_TEMPLATE"
    [xfce4-systemload-plugin]="''||'$xfce_url/panel-plugins/xfce4-systemload-plugin'||''||''||''||''||''||AUTOGEN_TEMPLATE"
    [xfce4-weather-plugin]="''||'$xfce_url/panel-plugins/xfce4-weather-plugin'||''||''||''||''||''||AUTOGEN_TEMPLATE"
    [xfce4-whiskermenu-plugin]="''||'$xfce_url/panel-plugins/xfce4-whiskermenu-plugin'||''||''||''||''||''||CMAKE_TEMPLATE"
    [xfce4-xkb-plugin]="''||'$xfce_url/panel-plugins/xfce4-xkb-plugin'||''||''||''||''||''||AUTOGEN_TEMPLATE"

    # thunar plugins
    [thunar-archive-plugin]="''||'$xfce_url/thunar-plugins/thunar-archive-plugin'||''||''||''||''||''||AUTOGEN_TEMPLATE"
    [thunar-media-tags-plugin]="''||'$xfce_url/thunar-plugins/thunar-media-tags-plugin'||''||''||''||''||''||AUTOGEN_TEMPLATE"
    [thunar-shares-plugin]="''||'$xfce_url/thunar-plugins/thunar-shares-plugin'||''||''||''||''||''||AUTOGEN_TEMPLATE"
    [thunar-vcs-plugin]="''||'$xfce_url/thunar-plugins/thunar-vcs-plugin'||''||''||''||''||''||AUTOGEN_TEMPLATE"
)

# These are packages which we are able find in the main repos
declare -A ARCH_MAIN_PACKAGES=(
    # apps
    [catfish]="''||'$xfce_url/apps/catfish'||''||''||''||''||''||PYTHON_TEMPLATE"
    [ristretto]="''||'$xfce_url/apps/ristretto'||''||''||''||''||''||AUTOGEN_TEMPLATE"
    [xfce4-dict]="''||'$xfce_url/apps/xfce4-dict'||''||''||''||''||''||AUTOGEN_TEMPLATE"

    # panel plugins
    [xfce4-battery-plugin]="''||'$xfce_url/panel-plugins/xfce4-battery-plugin'||''||''||''||''||''||AUTOGEN_TEMPLATE"
    [xfce4-calculator-plugin]="''||'$xfce_url/panel-plugins/xfce4-calculator-plugin'||''||''||''||''||''||AUTOGEN_TEMPLATE"
    [xfce4-cpugraph-plugin]="''||'$xfce_url/panel-plugins/xfce4-cpugraph-plugin'||''||''||''||''||''||AUTOGEN_TEMPLATE"
    [xfce4-mailwatch-plugin]="''||'$xfce_url/panel-plugins/xfce4-mailwatch-plugin'||''||''||''||''||''||AUTOGEN_TEMPLATE"
    [xfce4-mpc-plugin]="''||'$xfce_url/panel-plugins/xfce4-mpc-plugin'||''||''||''||''||''||AUTOGEN_TEMPLATE"
    [xfce4-notes-plugin]="''||'$xfce_url/panel-plugins/xfce4-notes-plugin'||''||''||''||''||''||AUTOGEN_TEMPLATE"
    [xfce4-sensors-plugin]="''||'$xfce_url/panel-plugins/xfce4-sensors-plugin'||''||''||''||''||''||AUTOGEN_TEMPLATE"
    [xfce4-timer-plugin]="''||'$xfce_url/panel-plugins/xfce4-timer-plugin'||''||''||''||''||''||AUTOGEN_TEMPLATE"
    [xfce4-verve-plugin]="''||'$xfce_url/panel-plugins/xfce4-verve-plugin'||''||''||''||''||''||AUTOGEN_TEMPLATE"
    [xfce4-wavelan-plugin]="''||'$xfce_url/panel-plugins/xfce4-wavelan-plugin'||''||''||''||''||''||AUTOGEN_TEMPLATE"
)

# These are packages we can find on AUR (better than nothing)
declare -A AUR_PACKAGES=(
    # apps
    [xfce4-mixer]="''||'$xfce_url/apps/xfce4-mixer'||''||''||''||''||''||AUTOGEN_TEMPLATE"

    # panel plugins
    [xfce4-indicator-plugin]="''||'$xfce_url/panel-plugins/xfce4-indicator-plugin'||''||''||''||''||''||AUTOGEN_TEMPLATE"
    [xfce4-places-plugin]="''||'$xfce_url/panel-plugins/xfce4-places-plugin'||''||''||''||''||''||AUTOGEN_TEMPLATE"
    [xfce4-statusnotifier-plugin]="''||'$xfce_url/panel-plugins/xfce4-statusnotifier-plugin'||''||''||''||''||''||AUTOGEN_TEMPLATE"
)

# all packages to be built: 65
ALL_XFCE_PACKAGES=(
    "${!AUR_GIT_PACKAGES[@]}" "${!ARCH_MAIN_PACKAGES[@]}"
    "${!AUR_PACKAGES[@]}"
)

# The name of the package is $1 and the values
# is read from stdin
function gen_PKGBUILD() {
  eval "
    local name='$1'
    $(awk -F '[|]{2}' '{
        print "local description="$1
        print "local url="$2
        print "local license="$3
        print "local depends="$4
        print "local makedepends="$5
        print "local optdepends="$6
        print "local options="$7
        print "local template="$8
    }')"

  eval "cat <<EOF
  ${!template}
EOF
"
}

function create_PKGBUILD() {
    install -dm755 --owner="${DEFAULT_USER}" /tmp/xfce/"$1"
    local -nr arr=$2
    gen_PKGBUILD "$1" <<< "${arr[$1]}" >/tmp/xfce/"$1"/PKGBUILD
}

install -dm755 --owner="${DEFAULT_USER}" --group="${DEFAULT_USER}" /tmp/xfce
chmod g+s /tmp/xfce

for pkg in ${!AUR_GIT_PACKAGES[@]}; do
    create_PKGBUILD "$pkg" AUR_GIT_PACKAGES
done

for pkg in ${!ARCH_MAIN_PACKAGES[@]}; do
    create_PKGBUILD "$pkg" ARCH_MAIN_PACKAGES
done

for pkg in ${!AUR_PACKAGES[@]}; do
    create_PKGBUILD "$pkg" AUR_PACKAGES
done

# https://wiki.archlinux.org/index.php/Aurweb_RPC_interface#API_usage
AUR_RPC='https://aur.archlinux.org/rpc/?v=5'

# used to fetch the dependencies
function fetch_deps() {
    curl --silent \
        "$AUR_RPC&type=info&by=name$(printf '&arg[]=%s-git' ${!AUR_GIT_PACKAGES[@]})" \
        "$AUR_RPC&type=info&by=name$(printf '&arg[]=%s' ${!AUR_PACKAGES[@]})" \
            | jq -r '[.results[].Depends?] | flatten | join("\n")'

    # ARCH_WEB='https://archlinux.org/packages/search/json/'
    for arch_pkg in ${!ARCH_MAIN_PACKAGES[@]}; do
        kittypack --json "$arch_pkg"
    done | jq -csr '[.[].results[].depends[]?] | join("\n")'
}

# used to fetch makedependencies
function fetch_makedeps() {
    curl --silent \
        "$AUR_RPC&type=info&by=name$(printf '&arg[]=%s-git' ${!AUR_GIT_PACKAGES[@]})" \
        "$AUR_RPC&type=info&by=name$(printf '&arg[]=%s' ${!AUR_PACKAGES[@]})" \
            | jq -r '[.results[].MakeDepends?] | flatten | join("\n")'

    # ARCH_WEB='https://archlinux.org/packages/search/json/'
    for arch_pkg in ${!ARCH_MAIN_PACKAGES[@]}; do
        kittypack --json "$arch_pkg"
    done | jq -csr '[.[].results[].makedepends[]?] | join("\n")'
}

# remove dups, and remove built packages from dep list
function clean_deps() {
    sort --unique \
    | sed -E --silent --sandbox '
    # https://www.gnu.org/software/sed/manual/sed.html
    p; x
    :check {
        n
        # matches lines that end in -git, -devel or version bound
        /(-git|[<=>].+|-devel)$/ {
            x; G; s/^(.+)\n\1.*$/\1/M; x
            t check
        }
        h; p
    }
    b check' \
    | awk --source "BEGIN {
        # https://catonmat.net/awk-one-liners-explained-part-two
        $(printf 'xfce["%s"]=1\n' ${ALL_XFCE_PACKAGES[@]})
    }" --source '!xfce[$0]'
}

DEPS=( $(fetch_deps | clean_deps) )
# adwaita-icon-theme alsa-lib apr colord dbus-glib desktop-file-utils
# file gdk-pixbuf2 git glib2 gnome-themes-extra gnutls
# gst-plugins-base gst-plugins-base-libs gst-plugins-good gtk2 gtk3 gtk-doc
# gtk-engine-murrine gtksourceview3 hicolor-icon-theme ido intltool libburn
# libdbusmenu-gtk3 libexif libgtop libgudev libindicator-gtk2 libindicator-gtk3
# libisofs libkeybinder3 libmpd libnotify libpng libpulse
# librsvg libsm libsoup libunique libwnck3 libxklavier
# libxml2 libxpresent libxss libxtst lm_sensors make
# pkg-config polkit polkit-gnome pulseaudio python-cairo python-dbus
# python-gobject python-pexpect python-ptyprocess python-xdg qrencode samba
# startup-notification subversion taglib upower vte3>=0.38 xdg-utils
# xorg-iceauth xorg-xinit xorg-xrdb

MAKE_DEPS=( $(fetch_makedeps | clean_deps) )
# autoconf chrpath cmake ffmpegthumbnailer freetype2 git
# glade glib-perl gobject-introspection gtk3 gtk-doc hddtemp
# intltool libgepub libgsf libnotify libopenraw libtool
# libxslt meson netcat optipng perl-extutils-depends perl-extutils-pkgconfig
# perl-uri pkgconfig poppler-glib python python-distutils-extra sassc
# systemd vala

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
