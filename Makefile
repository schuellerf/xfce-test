.PHONY: build run test xephyr setup exec-only start

#just build and start the docker
start: build run

#only a helper for ubuntu
setup:
	sudo apt install -y xserver-xephyr docker.io

xephyr:
	-killall -q Xephyr
	Xephyr :1 -ac -screen 800x600 &

build:
	docker build --tag test-xfce-ubuntu:latest .

run: build exec-only

test-setup: xephyr
	-docker run --detach \
              --env DISPLAY=":1" \
              --volume /tmp/.X11-unix:/tmp/.X11-unix \
              test-xfce-ubuntu \
              /usr/bin/ldtp > .docker_ID
	-docker exec --detach $$(cat .docker_ID) xfce4-session
	./xfce4-session-default.py $$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $$(cat .docker_ID))

test-teardown:
	docker stop $$(cat .docker_ID)
	docker rm $$(cat .docker_ID)
	rm .docker_ID
	-killall -q Xephyr

start-clipman:
	./xfce4-start-clipman.py $$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $$(cat .docker_ID))

manual-session:
	-docker exec --tty --interactive $$(cat .docker_ID) /bin/bash

exec-only: test-setup start-clipman manual-session test-teardown
	
	
#start the LDTP environment to prepare automated scripts
prepare-automatic-tests:

automatic-tests:
