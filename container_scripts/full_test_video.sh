#!/usr/bin/env bash

export OVERLAY_FILE=${OVERLAY_FILE:-/tmp/video.txt}
export VIDEO="true"
export VIDEO_PREFIX=${VIDEO_PREFIX:-xfce-test_video_}

if [ -n ${TRAVIS_BRANCH} ]; then
    # append the travis branch to the video name
    # but replacing / with _
    export VIDEO_PREFIX="${VIDEO_PREFIX}${TRAVIS_BRANCH//\//_}_"
fi

/container_scripts/start_recording.sh

echo "Hello World!

This is an automatically created XFCE Test video.
It shows features of XFCE and tests some functionality" > ${OVERLAY_FILE}

sleep 8

echo "First we'll see only the main window
of some applications" > ${OVERLAY_FILE}

sleep 3

/container_scripts/make_screenshots.py

echo "Now let's start the 'behave' tests

(Fully automated GUI testing described in natural language)" > ${OVERLAY_FILE}
sleep 5

# This creates a logfile for behave (/tmp/text_all.txt)
# cuts the last 5 lines to a new file (/tmp/text_cut.txt) and has
# to _move_ the file to /tmp/video.txt for ffmpeg to properly get it displayed
cd /behave_tests

behave -D DEBUG_ON_ERROR | while read LINE; do
  echo "$LINE" | tee -a /tmp/text_all.txt
  tail -n5 /tmp/text_all.txt > /tmp/text_cut.txt
  mv /tmp/text_cut.txt ${OVERLAY_FILE}
done

/container_scripts/stop_recording.sh
