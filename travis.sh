#!/usr/bin/env bash

docker run --detach --env TRAVIS --env TRAVIS_BRANCH --env DISPLAY --env RESOLUTION="1024x768" --volume /tmp/.X11-unix:/tmp/.X11-unix test-xfce-ubuntu /usr/bin/dbus-run-session /usr/bin/xfce4-session > .docker_ID
sleep 10 # give xfce some time to start

docker exec $(cat .docker_ID) bash -c "cat ~/version_info.txt"

docker exec --detach $(cat .docker_ID) /usr/bin/dbus-run-session /usr/bin/ldtp || docker logs $(cat .docker_ID)
sleep 10 # give ldtp some time to start

docker exec $(cat .docker_ID) bash -c "/container_scripts/full_test_video.sh" || docker logs $(cat .docker_ID)

docker exec $(cat .docker_ID) bash -c "echo \"${clientsecrets}\" |base64 -d > /container_scripts/client_secrets.json"
docker exec $(cat .docker_ID) bash -c "echo \"${uploadvideooauth2}\" |base64 -d > /container_scripts/upload-video.py-oauth2.json "
docker exec $(cat .docker_ID) bash -c "/container_scripts/upload-video-travis.sh"  || docker logs $(cat .docker_ID)

docker exec $(cat .docker_ID) bash -c "ls -la /data"
docker exec $(cat .docker_ID) bash -c "ls -la /container_scripts"

docker exec $(cat .docker_ID) bash -c "cat ~/version_info.txt"
docker exec $(cat .docker_ID) bash -c "ls -la /tmp/*.log"
docker exec $(cat .docker_ID) bash -c "cat /tmp/*.log"

docker exec $(cat .docker_ID) bash -c "apt-cache policy libgtk-3-0"

