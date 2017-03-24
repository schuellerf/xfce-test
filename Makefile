.PHONY: build xephyr setup exec-only all avocado-tests manual-session

export AVOCADO_BRANCH=39.0
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
	docker build --tag schuellerf/xfce-test:latest .

test-setup: xephyr
	-docker run --detach \
              --env DISPLAY=":1" \
              --volume /tmp/.X11-unix:/tmp/.X11-unix:z \
              schuellerf/xfce-test:latest > .docker_ID

test-teardown:
	-docker exec $$(cat .docker_ID) xfce4-session-logout --logout
	docker stop $$(cat .docker_ID)
	docker rm $$(cat .docker_ID)
	rm .docker_ID
	-killall -q Xephyr

manual-session: test-setup run-manual-session test-teardown

run-manual-session:
	-docker exec --tty --interactive $$(cat .docker_ID) /bin/bash

run-behave-tests:
	docker cp behave $$(cat .docker_ID):/tmp
	docker exec --tty $$(cat .docker_ID) bash -c "cd /tmp/behave;behave"
	docker exec --tty $$(cat .docker_ID) bash -c "cat ~test_user/version_info.txt"

debug-behave-tests:
	docker cp behave $$(cat .docker_ID):/tmp
	docker exec --tty $$(cat .docker_ID) bash -c "cd /tmp/behave;behave -D DEBUG_ON_ERROR"
	docker exec --tty $$(cat .docker_ID) bash -c "cat ~test_user/version_info.txt"

# internal function - call screenshots instead
do-screenshots:
	rm -rf screenshots
	docker cp make_screenshots.py $$(cat .docker_ID):/tmp
	docker exec $$(cat .docker_ID) python /tmp/make_screenshots.py
	docker cp $$(cat .docker_ID):/screenshots .
	docker exec $$(cat .docker_ID) xfce4-session-logout --logout

screenshots: test-setup do-screenshots test-teardown
