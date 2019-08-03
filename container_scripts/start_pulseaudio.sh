#!/bin/bash
echo "load-module module-udev-detect tsched=0" |sudo tee /etc/pulse/default.pa
pulseaudio -vv >/tmp/pulseaudio.log 2>&1 &
sleep 3
pactl load-module module-null-sink sink_name=XFCETestAudio sink_properties=device.description="XFCETestAudio"
fg

