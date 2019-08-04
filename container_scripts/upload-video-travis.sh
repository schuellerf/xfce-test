#!/usr/bin/env bash

# just a wrapper for the python upload
cd /container_scripts;
for f in /data/*.mp4; do
    TITLE="XFCE-Test Video $(basename -s .mp4 $f)"
    DESCRIPTION="This is a video of a fully automatic GUI test performed by travis.
For details see https://github.com/schuellerf/xfce-test/

The versions of the applications in the video are the following:
$(cat ~xfce-test_user/version_info.txt)"
    sudo chmod a+rw /container_scripts/client_secrets.json
    sudo chmod a+rw /container_scripts/upload-video.py-oauth2.json
    python upload-video.py --file $f --title "${TITLE}"  --description "${DESCRIPTION}" --noauth_local_webserver
done
