#!/usr/bin/env bash

if xprop -root >/dev/null; then
  cd /data
  xfce4-session
else
  echo "-------------------"
  cat /xfce-test
  echo "-------------------"
  echo ""
  echo "Hi"\!
  echo "X11 does not seem to be available in Docker - please save the code above in a file"
  echo "called 'xfce-test' and execute it"
fi
