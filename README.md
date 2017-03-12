# XFCE Test
Currently this is just a playground to setup xfce in docker.  
This is not a full xfce/xubuntu installation but for now only installs the newest libxfce4ui and some plugins for testing

# Travis

The tests are run automatically by [travis](https://travis-ci.org/schuellerf/xfce-test).

[![Build Status](https://travis-ci.org/schuellerf/xfce-test.svg?branch=master)](https://travis-ci.org/schuellerf/xfce-test)

# Architecture

This test is set-up as a docker container which is displaying it's X11 content on a Xephyr instance on your screen.

The first process to be started is [LDTP](https://ldtp.freedesktop.org/wiki/)
As "toolkit-accessibility" is activated (see Dockerfile) LDTP provides an XMLRPC port to run automated tests.

On top of LDTP there is [Avocado](https://github.com/avocado-framework/) running a series of tests.
Which tests are run depends on the target you are using in the Makefile.

You can also just start the container and "play around" in the newest XFCE environment...

# Preparations

either "read" the Makefile :) or at least assure docker and Xephyr to be on-board

```
sudo apt install -y xserver-xephyr docker.io
```

# Usage

If you don't want to build this docker image on your own (with the Makefile from github) you should

 * pull the image from docker-hub
 * start Xephyr
 * run the container (having the X11 displayed in Xephyr)

here are those steps as copy'n'paste lines

```
docker pull schuellerf/xfce-test:ubuntu_17.04
Xephyr :1 -ac -screen 800x600 &
docker run --name xfce-test --rm --env DISPLAY=":1" --volume /tmp/.X11-unix:/tmp/.X11-unix schuellerf/xfce-test:ubuntu_17.04
```

to _stop_ testing you can leave the xfce-session and close Xephyr or

```
killall Xephyr
```

or just close Xephyr - which would be "_the hard way_"

