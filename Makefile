.PHONY: build xephyr setup exec-only all manual-session

export RESOLUTION=800x600

# for experimenting you might want to start with
# make manual-session

$(info Don't forget to run make build or make pull)

all: behave-tests

check_env:
	if [ -z SRC_DIR ]; then echo "Please, set SRC_DIR where your sources are"; exit 1; fi

#use this to compile a git directory you have locally (even maybe modified)
compile-local: check_env xephyr
	-docker run --tty --interactive \
              --env DISPLAY=":1" \
              --volume /tmp/.X11-unix:/tmp/.X11-unix --volume $(SRC_DIR):/data \
              schuellerf/xfce-test:latest /bin/bash

# see compile-local
# this starts as root to be able to install stuff with apt
compile-local-root: check_env xephyr
	-docker run --tty --interactive --user 0:0 \
              --name xfce-test \
              --env DISPLAY=":1" \
              --volume /tmp/.X11-unix:/tmp/.X11-unix --volume $(SRC_DIR):/data \
              schuellerf/xfce-test:latest /bin/bash

test: behave-tests

#only a helper for ubuntu
setup:
	sudo apt install -y xserver-xephyr docker.io

behave-tests:  test-setup run-behave-tests test-teardown
debug:  test-setup debug-behave-tests test-teardown

xephyr:
	-killall -q Xephyr
	Xephyr :1 -ac -screen $(RESOLUTION) &

pull:
	docker pull schuellerf/xfce-test

build:
	docker build --build-arg DOWNLOAD_DATE=$(shell date +%Y%m%d) --tag schuellerf/xfce-test:latest .

test-setup: xephyr
	-docker rm xfce-test
	-docker run --name xfce-test --detach \
              --env DISPLAY=":1" \
              --volume /tmp/.X11-unix:/tmp/.X11-unix:z \
              schuellerf/xfce-test:latest

test-teardown:
	-docker exec xfce-test xfce4-session-logout --logout
	-docker stop xfce-test
	-docker rm xfce-test
	-killall -q Xephyr

manual-session: test-setup run-manual-session test-teardown

run-manual-session:
	-docker exec --tty --interactive xfce-test /bin/bash

run-behave-tests:
	docker cp behave xfce-test:/tmp
	docker exec --tty xfce-test bash -c "cd /tmp/behave;behave"
	docker exec --tty xfce-test bash -c "cat ~test_user/version_info.txt"

debug-behave-tests:
	docker cp behave xfce-test:/tmp
	docker exec --tty xfce-test bash -c "cd /tmp/behave;behave -D DEBUG_ON_ERROR"
	docker exec --tty xfce-test bash -c "cat ~test_user/version_info.txt"

test-like-travis:
	Xvfb :99 -ac -screen 0 800x600x24 &
	docker run --name xfce-test-travis --detach --env DISPLAY=:99.0 --volume /tmp/.X11-unix:/tmp/.X11-unix schuellerf/xfce-test:latest /usr/bin/dbus-run-session /usr/bin/ldtp
	ffmpeg -y -r 30 -f x11grab -s 800x600 -i :99.0 -c:a copy -f mpegts - 2>/dev/null|ffplay - 2>/dev/null 1>&1 &
	docker exec --detach xfce-test-travis xfce4-session
	docker cp behave xfce-test-travis:/tmp
	docker exec xfce-test-travis bash -c "cd /tmp/behave;behave -D DEBUG_ON_ERROR"
	-kill $$(cat /tmp/.X99-lock)
	-docker stop xfce-test-travis
	-docker rm xfce-test-travis
	-killall ffmpeg

# internal function - call screenshots instead
do-screenshots:
	rm -rf screenshots
	docker cp make_screenshots.py xfce-test:/tmp
	docker exec xfce-test python /tmp/make_screenshots.py
	docker cp xfce-test:/screenshots .
	docker exec xfce-test xfce4-session-logout --logout

screenshots: test-setup do-screenshots test-teardown
