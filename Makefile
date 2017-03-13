.PHONY: build xephyr setup exec-only all avocado-tests manual-session

export AVOCADO_BRANCH=39.0

# for experimenting you might want to start with
# make manual-session

all: avocado-tests

test: test-setup run-avocado-tests test-teardown

#only a helper for ubuntu
setup:
	sudo apt install -y xserver-xephyr docker.io

avocado-tests: test-setup run-avocado-tests run-manual-session test-teardown

manual-session: test-setup start-clipman run-manual-session test-teardown

xephyr:
	-killall -q Xephyr
	Xephyr :1 -ac -screen 800x600 &

build:
	docker build --tag test-xfce-ubuntu:latest .

test-setup: build xephyr
	-docker run --detach \
              --env DISPLAY=":1" \
              --volume /tmp/.X11-unix:/tmp/.X11-unix \
              test-xfce-ubuntu > .docker_ID

test-teardown:
	docker stop $$(cat .docker_ID)
	docker rm $$(cat .docker_ID)
	rm .docker_ID
	-killall -q Xephyr

#just as a demo
start-clipman:
	docker cp ./xfce4-start-clipman.py $$(cat .docker_ID):/tmp
	docker exec $$(cat .docker_ID) /tmp/xfce4-start-clipman.py 127.0.0.1

run-manual-session:
	-docker exec --tty --interactive $$(cat .docker_ID) /bin/bash

run-avocado-tests:
	docker cp tests $$(cat .docker_ID):/tmp
	docker exec $$(cat .docker_ID) avocado run /tmp/tests/
	docker cp $$(cat .docker_ID):/root/avocado .
	@echo "AUTOMATIC TESTS DONE"

