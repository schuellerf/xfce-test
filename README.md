# XFCE Test
Currently this is just a playground to setup xfce in docker.  
This is a xubuntu 17.04, with a build from git sources of all core Xfce components + some apps for testing.

# Travis

The tests are run automatically by [travis](https://travis-ci.org/schuellerf/xfce-test).

[![Build Status](https://travis-ci.org/schuellerf/xfce-test.svg?branch=master)](https://travis-ci.org/schuellerf/xfce-test)

# Architecture

This test is set-up as a docker container which is displaying it's X11 content on a Xephyr instance on your screen.

The first process to be started is [LDTP](https://ldtp.freedesktop.org/wiki/)
As "toolkit-accessibility" is activated (see Dockerfile) LDTP provides an XMLRPC port to run automated tests.

On top of LDTP there is [Behave](https://github.com/behave/behave) running a series of tests.

You can also just start the container and "play around" in the newest XFCE environment...
```
make manual-session
```

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
docker pull schuellerf/xfce-test:latest
Xephyr :1 -ac -screen 800x600 &
docker run --name xfce-test --rm --env DISPLAY=":1" --volume /tmp/.X11-unix:/tmp/.X11-unix schuellerf/xfce-test:latest
```

to _stop_ testing you can leave the xfce-session and close Xephyr or

```
killall Xephyr
```

or just close Xephyr - which would be "_the hard way_"

# Tests

To inspect stuff inside the docker to help create more tests you might want to start `sniff` which will help you identify the windows and buttons for LDTP.

You should start the tests with
```
make debug
```
This way the tests will stop executing and stay in the python debugger once a step fails.
Once this happens you can inspect the current state of "behave" or checkout the current state in the Xephyr window or open up a second shell and start `make run-manual-session` to examine the current state


# Package compilation

You can also use this container as test and compilation environment.
When you are in a source folder of a component (e.g. xfce4-panel) then you should set the `SRC_DIR` to be a full path e.g.
```
your_host:~/xfce4-panel$ export SRC_DIR=$(pwd)
```
then start your compile and test enviroment (assuming that you have https://github.com/schuellerf/xfce-test checked out in your home)
```
your_host:~/xfce4-panel$ make -C ~/xfce-test compile-local
```
then you can go into the directory `/data` in the docker container and compile/install and test in the Xephyr window

finally quit the bash of the docker container and tear down the container and Xephyr with

```
your_host:~/xfce4-panel$ make -C ~/xfce-test test-teardown
```
