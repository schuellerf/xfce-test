#!/usr/bin/env bash

XFCE_BASE=git://git.xfce.org

# (BRANCH URL NAME) tuples:
REPOS=( "master ${XFCE_BASE}/xfce/xfce4-dev-tools xfce4-dev-tools")
REPOS+=("master ${XFCE_BASE}/xfce/garcon garcon")
REPOS+=("master ${XFCE_BASE}/xfce/libxfce4ui libxfce4ui")
REPOS+=("master ${XFCE_BASE}/xfce/libxfce4util libxfce4util")
REPOS+=("master ${XFCE_BASE}/xfce/thunar thunar")
REPOS+=("master ${XFCE_BASE}/xfce/tumbler tumbler")
REPOS+=("master ${XFCE_BASE}/xfce/xfce4-appfinder xfce4-appfinder")
REPOS+=("master ${XFCE_BASE}/xfce/xfce4-panel xfce4-panel")
REPOS+=("master ${XFCE_BASE}/xfce/xfce4-power-manager xfce4-power-manager")
REPOS+=("master ${XFCE_BASE}/xfce/xfce4-session xfce4-session")
REPOS+=("master ${XFCE_BASE}/xfce/xfce4-settings xfce4-settings")
REPOS+=("master ${XFCE_BASE}/xfce/xfconf xfconf")
REPOS+=("master ${XFCE_BASE}/xfce/xfdesktop xfdesktop")
REPOS+=("master ${XFCE_BASE}/xfce/xfwm4 xfwm4")
REPOS+=("master ${XFCE_BASE}/apps/xfce4-notifyd xfce4-notifyd")
REPOS+=("master ${XFCE_BASE}/apps/xfce4-taskmanager xfce4-taskmanager")
REPOS+=("master ${XFCE_BASE}/apps/xfce4-terminal xfce4-terminal")
REPOS+=("master ${XFCE_BASE}/apps/xfce4-screenshooter xfce4-screenshooter")
REPOS+=("master ${XFCE_BASE}/panel-plugins/xfce4-whiskermenu-plugin xfce4-whiskermenu-plugin")
REPOS+=("master ${XFCE_BASE}/panel-plugins/xfce4-clipman-plugin xfce4-clipman-plugin")

for tuple in "${REPOS[@]}"; do
    set -- $tuple
    BRANCH=$1
    URL=$2
    NAME=$3
    echo "--- Building $NAME ($BRANCH) ---"
    cd /git
    git clone --branch $BRANCH $URL
    cd $NAME
    ./autogen.sh $AUTOGEN_OPTIONS
    make -j8
    make install
    echo "$(pwd): $(git describe)" >> ~xfce-test_user/version_info.txt
done

