#!/usr/bin/env bash

export OVERLAY_FILE=${OVERLAY_FILE:-/tmp/video.txt}

/container_scripts/start_recording.sh

echo ""

HINT="(The text you enter will appear in the video, an empty line will stop the video) "

while true; do
    read -p "What are you doing now? ${HINT}"
    HINT=""
    if [ -z "$REPLY" ]; then
        break
    fi
    echo "$REPLY" > ${OVERLAY_FILE}
done

/container_scripts/stop_recording.sh

