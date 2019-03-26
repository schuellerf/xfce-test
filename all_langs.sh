#!/usr/bin/env bash


ALL_LANGS="$(locale -a)"
PROGRAM=xfce4-display-settings

# move the mouse away
xte 'mousemove 10000 10000'

for L in $ALL_LANGS; do
        export LANG=$L
        xfce4-screenshooter -d 1 -s "${PROGRAM}_${L}.png" -w &
        shooter_pid=$!
        $PROGRAM &
        proggie_pid=$!
        wait $shooter_pid
        kill $proggie_pid
done
