#!/bin/env bash

RESOLUTION=${RESOLUTION:-800x600}

ffmpeg -y -r 30 -f x11grab -s ${RESOLUTION} -i :99.0 -vf "drawtext=fontfile=Vera.ttf:textfile=/tmp/video.txt:reload=1:fontcolor=white: fontsize=12: box=1: boxcolor=black@0.5:y=500" -c:v libx264 -f mpegts - 2>/data/video_log > /data/video.ts &
