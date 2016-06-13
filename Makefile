.PHONY: build run test xephyr setup


setup:
	sudo apt install -y xserver-xephyr docker.io

xephyr:
	-killall -q Xephyr
	Xephyr :1 -ac -screen 800x600 &

test: build run
build:
	docker build -t test-xfce-ubuntu .
run: xephyr
	-docker run -ti --rm \
        -e DISPLAY=":1" \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
	test-xfce-ubuntu \
        /bin/bash
	-killall -q Xephyr

