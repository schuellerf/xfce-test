#!/usr/bin/env bash

XFCE_BASE=https://gitlab.xfce.org

MAIN_BRANCH=${MAIN_BRANCH:-last_release}

VERSION_FILE="/home/${DEFAULT_USER:-xfce-test_user}/version_info.txt"

echo "# The OK marks if building this component in the current container was successful" >> $VERSION_FILE

# (BUILD_TYPE BRANCH URL NAME) tuples:
REPOS=("autogen ${MAIN_BRANCH} ${XFCE_BASE}/xfce/xfce4-dev-tools.git xfce4-dev-tools")
REPOS+=("sync")
REPOS+=("autogen ${MAIN_BRANCH} ${XFCE_BASE}/xfce/libxfce4util.git libxfce4util")
REPOS+=("sync")
REPOS+=("autogen ${MAIN_BRANCH} ${XFCE_BASE}/xfce/xfconf.git xfconf")
REPOS+=("sync")
REPOS+=("autogen ${MAIN_BRANCH} ${XFCE_BASE}/xfce/libxfce4ui.git libxfce4ui")
REPOS+=("sync")
REPOS+=("autogen ${GARCON_BRANCH:-$MAIN_BRANCH} ${XFCE_BASE}/xfce/garcon.git garcon")
REPOS+=("sync")
REPOS+=("autogen ${MAIN_BRANCH} ${XFCE_BASE}/xfce/exo.git exo")
REPOS+=("sync")
REPOS+=("autogen ${MAIN_BRANCH} ${XFCE_BASE}/xfce/xfce4-panel.git xfce4-panel")
REPOS+=("autogen ${MAIN_BRANCH} ${XFCE_BASE}/xfce/thunar.git thunar")
REPOS+=("autogen ${MAIN_BRANCH} ${XFCE_BASE}/xfce/thunar-volman.git thunar-volman")
REPOS+=("autogen ${MAIN_BRANCH} ${XFCE_BASE}/xfce/xfce4-power-manager.git xfce4-power-manager")
REPOS+=("autogen ${MAIN_BRANCH} ${XFCE_BASE}/xfce/xfce4-settings.git xfce4-settings")
REPOS+=("autogen ${MAIN_BRANCH} ${XFCE_BASE}/xfce/xfce4-session.git xfce4-session")
REPOS+=("autogen ${MAIN_BRANCH} ${XFCE_BASE}/xfce/xfdesktop.git xfdesktop")
REPOS+=("autogen ${MAIN_BRANCH} ${XFCE_BASE}/xfce/xfwm4.git xfwm4")
REPOS+=("autogen ${MAIN_BRANCH} ${XFCE_BASE}/xfce/xfce4-appfinder.git xfce4-appfinder")
REPOS+=("autogen ${MAIN_BRANCH} ${XFCE_BASE}/xfce/tumbler.git tumbler")
REPOS+=("autogen ${MAIN_BRANCH} ${XFCE_BASE}/bindings/xfce4-vala.git xfce4-vala")
REPOS+=("meson ${MAIN_BRANCH} https://github.com/shimmerproject/Greybird.git Greybird")
REPOS+=("sync")

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
    REPOS+=("autogen ${MAIN_BRANCH} ${XFCE_BASE}/apps/$a.git $a")
done

REPOS+=("make ${MAIN_BRANCH} ${XFCE_BASE}/apps/xfce4-panel-profiles.git xfce4-panel-profiles --prefix=/usr")
REPOS+=("python ${MAIN_BRANCH} ${XFCE_BASE}/apps/catfish.git catfish")

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
xfce4-pulseaudio-plugin
xfce4-statusnotifier-plugin
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

# xfce4-mailwatch-plugin - not compatible with libxfce4panel-2 and libxfce4ui-2
# xfce4-verve-plugin - not yet compatible with libxfce4panel-2 and libxfce4ui-2
# xfce4-notes-plugin - not yet compatible with new xfconf and libxfce4ui interfaces

for a in $panelplugins; do
    REPOS+=("autogen ${MAIN_BRANCH} ${XFCE_BASE}/panel-plugins/$a.git $a")
done

REPOS+=("cmake ${MAIN_BRANCH} ${XFCE_BASE}/panel-plugins/xfce4-whiskermenu-plugin.git xfce4-whiskermenu-plugin")
REPOS+=("iconmake ${MAIN_BRANCH} https://github.com/shimmerproject/elementary-xfce.git elementary-xfce")

thunarplugins="thunar-archive-plugin
thunar-media-tags-plugin"

for a in $thunarplugins; do
    REPOS+=("autogen ${MAIN_BRANCH} ${XFCE_BASE}/thunar-plugins/$a.git $a")
done


build() {
    BUILD_TYPE=$1
    BRANCH=$2
    URL=$3
    NAME=$4
    PARAMS=$5
    echo "--- Building $NAME ($BRANCH) ---"
    echo "    Params: $PARAMS"
    cd /git
    MODULE="$NAME"

    SUBSEQUENT_RUN=0

    if [ ! -d $NAME ]; then
        git clone $URL $NAME|| export MODULE="$NAME cloning failed"
        SUBSEQUENT_RUN=0
    else
        echo "Subsequent run - skip cloning"
        SUBSEQUENT_RUN=1
    fi

    cd $NAME || export MODULE="$NAME cloning failed"
    if [ "$BRANCH" == "last_release" ]; then
        # then start searching the last release before the given DOWNLOAD_DATE
        BRANCH=$(git describe --abbrev=0 --tags $(git rev-list --tags --before="${DOWNLOAD_DATE}" master) 2>/dev/null|egrep "xfce-[0-9]+\.[0-9]+.*"|sort -u  --version-sort|tail -n1)

        git checkout $BRANCH || echo "Branch $BRANCH not found - leaving default"
    elif [ "$BRANCH" == "last_tag" ]; then
        # for more reproducable behavior go given time on master
        git checkout $(git rev-list -1 --before="${DOWNLOAD_DATE}" master) || echo "Can't switch to specific date $DOWNLOAD_DATE"

        # then start searching the last tag
        BRANCH=$(git describe --abbrev=0)

        git checkout $BRANCH || echo "Branch $BRANCH not found - leaving default"
    elif git show-ref --verify refs/remotes/origin/$BRANCH &>/dev/null; then
        # if it's a branch go back to the requested time
        # for more reproducable behavior
        git checkout $(git rev-list -1 --before="${DOWNLOAD_DATE}" ${BRANCH}) || echo "Can't switch to specific date $DOWNLOAD_DATE - leaving as is on $BRANCH"
    elif git show-ref --verify refs/tags/$BRANCH &>/dev/null; then
        git checkout $BRANCH || echo "Tag $BRANCH not found - leaving default"
    else
        echo "$BRANCH is neither a tag nor a branch!?"
        git checkout $BRANCH || echo "$BRANCH not found - leaving default"
    fi

    #WORKAROUNDS
    if [ "$NAME" == "xfce4-vala" ]; then
        sed -i "s/vala_api='0...'/vala_api='0.48'/" configure.ac.in
    fi

    python3 /container_scripts/patch_automate_po.py || echo "Just trying to create the \"automate\" language as a first test"

    case $BUILD_TYPE in
        "autogen")
            if [ $SUBSEQUENT_RUN -eq 1 ]; then
                sudo make uninstall
                sudo chown -R ${DEFAULT_USER:-xfce-test_user}: .
            fi

            ./autogen.sh $PARAMS
            make -j8 >$PIPE
            RET=$?

            sudo make install >$PIPE
        ;;
        "make")
            if [ $SUBSEQUENT_RUN -eq 1 ]; then
                sudo make uninstall
                sudo chown -R ${DEFAULT_USER:-xfce-test_user}: .
            fi

            ./configure $PARAMS
            make -j8 >$PIPE
            RET=$?

            sudo make install >$PIPE
        ;;
        "iconmake")
            if [ $SUBSEQUENT_RUN -eq 1 ]; then
                sudo make uninstall
                sudo chown -R ${DEFAULT_USER:-xfce-test_user}: .
            fi

            ./configure $PARAMS
            make -j8 >$PIPE
            RET=$?

            sudo make install >$PIPE
            sudo make icon-caches >$PIPE
        ;;
        "cmake")
            if [ $SUBSEQUENT_RUN -eq 1 ]; then
                cd build
                sudo make uninstall
                sudo chown -R ${DEFAULT_USER:-xfce-test_user}: ..
            else
                mkdir build
                cd build
            fi
            cmake -DCMAKE_INSTALL_PREFIX=/usr .. >$PIPE
            make -j8 >$PIPE
            RET=$?

            sudo make install >$PIPE
        ;;
        "python")
            [ $SUBSEQUENT_RUN -eq 1 ] && sudo xargs rm -rf < .installed-files.txt
            python3 setup.py build
            RET=$?

            sudo python3 setup.py install --record .installed-files.txt >$PIPE
        ;;
        "meson")
            if [ $SUBSEQUENT_RUN -eq 1 ]; then
                pushd builddir
                sudo ninja uninstall
                popd
                sudo chown -R ${DEFAULT_USER:-xfce-test_user}: .
            fi
            meson --prefix=/usr builddir
            cd builddir
            ninja
            RET=$?

            sudo ninja install
        ;;
        *)
            echo "Unknown build type: >$1<"
            RET=1
        ;;
    esac
    flock -x $LOCK_FD
    sudo ldconfig
    if [ $RET -eq 0 ]; then
        echo -n "    OK: " >> $VERSION_FILE
    else
        echo -n "NOT OK: " >> $VERSION_FILE
    fi
    echo "${MODULE}: $(git describe)" >> $VERSION_FILE
    flock -u $LOCK_FD
}

LOCKFILE=/tmp/$$.lock
touch $LOCKFILE
exec {LOCK_FD}<>$LOCKFILE

if [ "$TRAVIS" == "FALSE" ]; then
  PIPE=/dev/stdout
else
  echo Filtered package output to save output log size
  PIPE=/dev/null
fi

PARALLEL_BUILDS=${PARALLEL_BUILDS:-1}
export LOCK_FD
echo "Building $PARALLEL_BUILDS in parallel"
echo "With AUTOGEN_OPTIONS: $AUTOGEN_OPTIONS"
i=0
for tuple in "${REPOS[@]}"; do
    set -- $tuple
    BUILD_TYPE=$1
    BRANCH=$2
    URL=$3
    NAME=$4
    PARAMS=${5:-$AUTOGEN_OPTIONS}
    i=$(( $i + 1 ))
    if [ "$BUILD_TYPE" == "sync" ]; then
        wait
        echo " --- (${i}/${#REPOS[@]}) sync step for builds ---"
        continue
    fi
    if [ $(jobs -p |wc -w) -ge $PARALLEL_BUILDS ]; then
        wait -n
    fi
    build $BUILD_TYPE $BRANCH $URL $NAME "$PARAMS" 2>&1 | xargs -n1 -d '\n' echo "$NAME (${i}/${#REPOS[@]}): " &
done

wait
