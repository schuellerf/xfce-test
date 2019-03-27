#!/usr/bin/env bash


ALL_LANGS="$(locale -a)"
PROGRAM=xfce4-display-settings

# move the mouse away
xte 'mousemove 10000 10000'

NUM=$(echo "${ALL_LANGS}"|wc -w)
COUNT=1

for L in $ALL_LANGS; do
        export LANG=$L
        echo "Doing screenshot of ${PROGRAM} in language: ${L} (${COUNT}/${NUM})"
        COUNT=$(( $COUNT + 1 ))
        $PROGRAM &
        proggie_pid=$!
        xfce4-screenshooter -d 1 -s "${PROGRAM}_${L}.png" -w &
        shooter_pid=$!
        wait $shooter_pid 2>/dev/null
        kill $proggie_pid
done
