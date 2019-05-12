#!/usr/bin/env bash

export OVERLAY_FILE=${OVERLAY_FILE:-/tmp/video.txt}

/container_scripts/start_recording.sh

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
