#!/usr/bin/env bash

XFCE_BASE=git://git.xfce.org

MAIN_BRANCH=master

# (BRANCH URL NAME) tuples:
REPOS=( "${MAIN_BRANCH} ${XFCE_BASE}/xfce/libxfce4ui libxfce4ui")
REPOS+=("${MAIN_BRANCH} ${XFCE_BASE}/xfce/libxfce4util libxfce4util")
REPOS+=("${MAIN_BRANCH} ${XFCE_BASE}/xfce/exo exo")
REPOS+=("${MAIN_BRANCH} ${XFCE_BASE}/xfce/xfce4-dev-tools xfce4-dev-tools")
REPOS+=("${MAIN_BRANCH} ${XFCE_BASE}/xfce/xfce4-panel xfce4-panel")
REPOS+=("${MAIN_BRANCH} ${XFCE_BASE}/xfce/garcon garcon")
REPOS+=("${MAIN_BRANCH} ${XFCE_BASE}/xfce/thunar thunar")
REPOS+=("${MAIN_BRANCH} ${XFCE_BASE}/xfce/thunar-volman thunar-volman")
REPOS+=("${MAIN_BRANCH} ${XFCE_BASE}/xfce/xfce4-power-manager xfce4-power-manager")
REPOS+=("${MAIN_BRANCH} ${XFCE_BASE}/xfce/xfce4-settings xfce4-settings")
REPOS+=("${MAIN_BRANCH} ${XFCE_BASE}/xfce/xfce4-session xfce4-session")
REPOS+=("${MAIN_BRANCH} ${XFCE_BASE}/xfce/xfconf xfconf")
REPOS+=("${MAIN_BRANCH} ${XFCE_BASE}/xfce/xfdesktop xfdesktop")
REPOS+=("${MAIN_BRANCH} ${XFCE_BASE}/xfce/xfwm4 xfwm4")
REPOS+=("${MAIN_BRANCH} ${XFCE_BASE}/xfce/xfce4-appfinder xfce4-appfinder")
REPOS+=("${MAIN_BRANCH} ${XFCE_BASE}/xfce/tumbler tumbler")

APPS="catfish
gigolo
mousepad
parole
ristretto
xfburn
xfce4-dict
xfce4-mixer
xfce4-notifyd
xfce4-panel-profiles
xfce4-screensaver
xfce4-screenshooter
xfce4-taskmanager
xfce4-terminal
xfce4-volumed-pulse
xfmpc"

for a in $APPS; do
    REPOS+=("${MAIN_BRANCH} ${XFCE_BASE}/apps/$a $a")
done

panelplugins="
xfce4-battery-plugin
xfce4-calculator-plugin
xfce4-clipman-plugin
xfce4-cpufreq-plugin
xfce4-cpugraph-plugin
xfce4-datetime-plugin
xfce4-diskperf-plugin
xfce4-fsguard-plugin
xfce4-genmon-plugin
xfce4-indicator-plugin
xfce4-mailwatch-plugin
xfce4-netload-plugin
xfce4-netload-plugin
xfce4-places-plugin
xfce4-sensors-plugin
xfce4-smartbookmark-plugin
xfce4-systemload-plugin
xfce4-timer-plugin
xfce4-verve-plugin
xfce4-wavelan-plugin
xfce4-weather-plugin
xfce4-whiskermenu-plugin
xfce4-xkb-plugin
xfce4-mpc-plugin"

for a in $panelplugins; do
    REPOS+=("${MAIN_BRANCH} ${XFCE_BASE}/panel-plugins/$a $a")
done

thunarplugins="thunar-archive-plugin
thunar-media-tags-plugin"

for a in $thunarplugins; do
    REPOS+=("${MAIN_BRANCH} ${XFCE_BASE}/thunar-plugins/$a $a")
done


for tuple in "${REPOS[@]}"; do
    set -- $tuple
    BRANCH=$1
    URL=$2
    NAME=$3
    echo "--- Building $NAME ($BRANCH) ---"
    cd /git
    git clone $URL
    cd $NAME
    git checkout $BRANCH || echo "Branch $BRANCH not found - leaving default"
    ./autogen.sh $AUTOGEN_OPTIONS
    make -j8
    make install
    echo "$(pwd): $(git describe)" >> ~xfce-test_user/version_info.txt
done

