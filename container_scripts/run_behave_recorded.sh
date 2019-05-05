#!/usr/bin/env bash

/container_scripts/start_recording.sh

# This creates a logfile for behave (/tmp/text_all.txt)
# cuts the last 5 lines to a new file (/tmp/text_cut.txt) and has
# to _move_ the file to /tmp/video.txt for ffmpeg to properly get it displayed
cd /behave_tests

GUI_TIMEOUT=120 behave -D DEBUG_ON_ERROR | while read LINE; do
  echo "$LINE" | tee -a /tmp/text_all.txt
  tail -n5 /tmp/text_all.txt > /tmp/text_cut.txt
  mv /tmp/text_cut.txt /tmp/video.txt
done

/container_scripts/stop_recording.sh
