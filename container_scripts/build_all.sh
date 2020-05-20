#!/usr/bin/env bash

XFCE_BASE=git://git.xfce.org

MAIN_BRANCH=master

VERSION_FILE="/home/xfce-test_user/version_info.txt"

echo "# The OK marks if building this component in the current container was successful" >> $VERSION_FILE

# (BUILD_TYPE BRANCH URL NAME) tuples:
REPOS=( "autogen ${MAIN_BRANCH} ${XFCE_BASE}/xfce/libxfce4util libxfce4util")
REPOS+=("autogen ${MAIN_BRANCH} ${XFCE_BASE}/xfce/libxfce4ui libxfce4ui")
REPOS+=("autogen ${MAIN_BRANCH} ${XFCE_BASE}/xfce/exo exo")
REPOS+=("autogen ${MAIN_BRANCH} ${XFCE_BASE}/xfce/xfce4-dev-tools xfce4-dev-tools")
REPOS+=("autogen ${MAIN_BRANCH} ${XFCE_BASE}/xfce/xfce4-panel xfce4-panel")
REPOS+=("autogen ${MAIN_BRANCH} ${XFCE_BASE}/xfce/garcon garcon")
REPOS+=("autogen ${MAIN_BRANCH} ${XFCE_BASE}/xfce/thunar thunar")
REPOS+=("autogen ${MAIN_BRANCH} ${XFCE_BASE}/xfce/thunar-volman thunar-volman")
REPOS+=("autogen ${MAIN_BRANCH} ${XFCE_BASE}/xfce/xfce4-power-manager xfce4-power-manager")
REPOS+=("autogen ${MAIN_BRANCH} ${XFCE_BASE}/xfce/xfce4-settings xfce4-settings")
REPOS+=("autogen ${MAIN_BRANCH} ${XFCE_BASE}/xfce/xfce4-session xfce4-session")
REPOS+=("autogen ${MAIN_BRANCH} ${XFCE_BASE}/xfce/xfconf xfconf")
REPOS+=("autogen ${MAIN_BRANCH} ${XFCE_BASE}/xfce/xfdesktop xfdesktop")
REPOS+=("autogen ${MAIN_BRANCH} ${XFCE_BASE}/xfce/xfwm4 xfwm4")
REPOS+=("autogen ${MAIN_BRANCH} ${XFCE_BASE}/xfce/xfce4-appfinder xfce4-appfinder")
REPOS+=("autogen ${MAIN_BRANCH} ${XFCE_BASE}/xfce/tumbler tumbler")

APPS="gigolo
mousepad
parole
ristretto
xfburn
xfce4-dict
xfce4-mixer
xfce4-notifyd
xfce4-screensaver
xfce4-screenshooter
xfce4-taskmanager
xfce4-terminal
xfce4-volumed-pulse
xfmpc"

for a in $APPS; do
    REPOS+=("autogen ${MAIN_BRANCH} ${XFCE_BASE}/apps/$a $a")
done

REPOS+=("make ${MAIN_BRANCH} ${XFCE_BASE}/apps/xfce4-panel-profiles xfce4-panel-profiles")
REPOS+=("python ${MAIN_BRANCH} ${XFCE_BASE}/apps/catfish catfish")

panelplugins="
xfce4-notes-plugin
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
xfce4-xkb-plugin
xfce4-mpc-plugin"

for a in $panelplugins; do
    REPOS+=("autogen ${MAIN_BRANCH} ${XFCE_BASE}/panel-plugins/$a $a")
done

REPOS+=("cmake ${MAIN_BRANCH} ${XFCE_BASE}/panel-plugins/xfce4-whiskermenu-plugin xfce4-whiskermenu-plugin")

thunarplugins="thunar-archive-plugin
thunar-media-tags-plugin"

for a in $thunarplugins; do
    REPOS+=("autogen ${MAIN_BRANCH} ${XFCE_BASE}/thunar-plugins/$a $a")
done


for tuple in "${REPOS[@]}"; do
    set -- $tuple
    BUILD_TYPE=$1
    BRANCH=$2
    URL=$3
    NAME=$4
    echo "--- Building $NAME ($BRANCH) ---"
    cd /git
    git clone $URL
    cd $NAME
    git checkout $BRANCH || echo "Branch $BRANCH not found - leaving default"
    case $BUILD_TYPE in
        "autogen")
            ./autogen.sh $AUTOGEN_OPTIONS
            make -j8
            RET=$?
            sudo make install
        ;;
        "make")
            ./configure $AUTOGEN_OPTIONS
            make -j8
            RET=$?
            sudo make install
        ;;
        "cmake")
            mkdir build && cd build
            cmake ..
            make -j8
            RET=$?
            sudo make install
        ;;
        "python")
            python setup.py build
            RET=$?
            sudo python setup.py install
        ;;
        *)
            echo "Unknown build type: >$1<"
            RET=1
        ;;
    esac
    if [ $RET -eq 0 ]; then
        echo -n "    OK: " >> $VERSION_FILE
    else
        echo -n "NOT OK: " >> $VERSION_FILE
    fi
    echo "$(pwd): $(git describe)" >> $VERSION_FILE
done

