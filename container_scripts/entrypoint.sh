#!/usr/bin/env bash

if xprop -root >/dev/null; then
  xfce4-session
else
  echo "-------------------"
  cat /start.sh
  echo "-------------------"
  echo ""
  echo "Hi"\!
  echo "X11 does not seem to be available in Docker - please save the code above in a file"
  echo "called 'start.sh' and execute it"
fi
