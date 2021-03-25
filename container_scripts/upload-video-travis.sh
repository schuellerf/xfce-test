#!/usr/bin/env bash

# just a wrapper for the python upload
cd /container_scripts;
for f in /data/*.mp4; do
    TITLE="XFCE-Test Video $(basename -s .mp4 $f)"
    DESCRIPTION="This is a video of a fully automatic GUI test performed by travis.
For details see https://github.com/schuellerf/xfce-test/

The versions of the applications in the video are the following:
$(cat ~${DEFAULT_USER:-xfce-test_user}/version_info.txt)"
    python3 upload-video.py --file $f --title "${TITLE}"  --description "${DESCRIPTION}" --noauth_local_webserver
done
