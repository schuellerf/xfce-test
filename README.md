# XFCE Test
Currently this is just a playground to setup xfce in docker.  
This is not a full xfce/xubuntu installation but for now only installs the newest libxfce4ui and clipman plugin for testing

# Architecture

This test is set-up as a docker container which is displaying it's X11 content on a Xephyr instance on your screen.

The first process to be started is [LDTP](https://ldtp.freedesktop.org/wiki/)
As "toolkit-accessibility" is activated (see Dockerfile) LDTP provides an XMLRPC port to run automated tests.

On top of LDTP there is [Avocado](https://github.com/avocado-framework/) running a series of tests.
Which tests are run depends on the target you are using in the Makefile.

You can also just start the container and "play around" in the newest XFCE environment...

