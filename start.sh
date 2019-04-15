#!/usr/bin/env bash

# This starts the container for manual or semi automated tests

# resolution of the test X server
# TBD: define what the minimal supported resolution is
export RESOLUTION=1024x768

# use this X display number for the tests
export DISPLAY_NUM=1

# set SCREENSHOTS to ALWAYS to get screenshots during behave tests
export SCREENSHOTS=NONE

# quit on errors
set +e

# TBD replace by nicer check
if [ -f /etc/lsb-release ] && grep Ubuntu /etc/lsb-release >/dev/null; then
  UBUNTU_PACKAGES="xserver-xephyr docker.io xvfb ffmpeg"

  for package in ${UBUNTU_PACKAGES}; do
    if ! apt list --installed 2>/dev/null|grep "^$package" >/dev/null; then
      sudo apt install -y $package
    fi
  done
fi

# kill an already running instance if still running from the last test
killall -q Xephyr

Xephyr :${DISPLAY_NUM} -ac -screen ${RESOLUTION} &

docker rm xfce-test || echo "^ That's ok, just _tried_ to remove existing container"
echo ""

echo -n "Starting container: "
docker run --name xfce-test --detach \
           --env DISPLAY=":${DISPLAY_NUM}" \
           --env LDTP_DEBUG=2 \
           --env SCREENSHOTS=${SCREENSHOTS} \
           --volume ${PWD}:/data \
           --volume /tmp/.X11-unix:/tmp/.X11-unix:z \
           schuellerf/xfce-test:latest

docker exec --tty --interactive xfce-test /bin/bash

# Tear down
docker exec xfce-test xfce4-session-logout --logout
docker stop xfce-test
docker rm xfce-test
killall -q Xephyr
rm -rf /tmp/.X11-unix/X${DISPLAY_NUM} /tmp/.X${DISPLAY_NUM}-lock

