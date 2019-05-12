#!/usr/bin/env bash

RESOLUTION=${RESOLUTION:-800x600}
DATE=$(date +%Y%m%d_%H%M%S)
OVERLAY_FILE=${OVERLAY_FILE:-/tmp/video.txt}
VIDEO_PREFIX=${VIDEO_PREFIX:-xfce-test_video_}

# assure file is existing and there is at least a newline
echo "" > ${OVERLAY_FILE}

ffmpeg -y -r 30 -f x11grab -s ${RESOLUTION} -i ${DISPLAY} -vf "drawtext=fontfile=Vera.ttf:textfile=${OVERLAY_FILE}:reload=1:fontcolor=white: fontsize=12: box=1: boxcolor=black@0.5:y=500" -c:v libx264 -pix_fmt yuv420p -movflags frag_keyframe+empty_moov -f mp4 - 2>/data/${VIDEO_PREFIX}${DATE}.log > /data/${VIDEO_PREFIX}${DATE}.mp4 &
date +%s > /tmp/video_start_time

echo "Started recording to /data/${VIDEO_PREFIX}${DATE}.mp4"
