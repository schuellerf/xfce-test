#!/bin/bash
pulseaudio -vv &
sleep 3
pactl load-module module-null-sink sink_name=XFCETestAudio sink_properties=device.description="XFCETestAudio"
fg

