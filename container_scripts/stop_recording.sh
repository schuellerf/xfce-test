#!/usr/bin/env bash

killall ffmpeg
date +%s > /tmp/video_stop_time

echo "Recording stopped."

VIDEO_LEN=$(( $(cat /tmp/video_stop_time) - $(cat /tmp/video_start_time) ))
VIDEO_TIME=$(date --utc --date=@${VIDEO_LEN} +%T)
echo "The video has ${VIDEO_LEN} seconds (${VIDEO_TIME})"
