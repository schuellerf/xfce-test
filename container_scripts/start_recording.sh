#!/usr/bin/env bash

RESOLUTION=${RESOLUTION:-800x600}
DATE=$(date +%Y%m%d_%H%M%S)
OVERLAY_FILE=${OVERLAY_FILE:-/tmp/video.txt}
VIDEO_PREFIX=${VIDEO_PREFIX:-xfce-test_video_}

# assure file is existing and there is at least a newline
echo "" > ${OVERLAY_FILE}

ffmpeg -y -r 30 -f x11grab -s ${RESOLUTION} -i ${DISPLAY} -vf "drawtext=fontfile=Vera.ttf:textfile=${OVERLAY_FILE}:reload=1:fontcolor=white: fontsize=12: box=1: boxcolor=black@0.5:y=500" -c:v libx264 -f mpegts - 2>/data/${VIDEO_PREFIX}${DATE}.log > /data/${VIDEO_PREFIX}${DATE}.ts &
