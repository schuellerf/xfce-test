#!/usr/bin/env python

import ldtp as l
import os
import time
import sys
import shutil

basePath="/data/app_screenshots"

if not os.path.exists(basePath):
    os.mkdir(basePath)

def do_screenshot(app, app_name):
  print("Doing screenhot for {}".format(app_name))
  l.launchapp(app)
  l.waittillguiexist(app_name)
  l.imagecapture(app_name, os.path.join(basePath, app + ".png"))
  full_screen=l.imagecapture()
  shutil.move(full_screen, os.path.join(basePath, "fullscreen-" + app + ".png"))
  l.generatekeyevent("<alt><f4>")


full_screen=l.imagecapture()
shutil.move(full_screen, os.path.join(basePath, "xfce-desktop.png"))

# I/O error workaround
l.launchapp("xfce4-terminal")
time.sleep(1)
l.generatekeyevent("<alt><f4>")


# move the mouse away to avoid tool tips
l.generatemouseevent(800,600, "abs")


do_screenshot("xfce4-appfinder", "ApplicationFinder")
do_screenshot("xfce4-terminal", "Terminal*")
do_screenshot("xfce4-clipman-settings", "Clipman")
do_screenshot("xfce4-display-settings", "Display")
do_screenshot("xfce4-keyboard-settings", "Keyboard")
do_screenshot("xfce4-mime-settings", "MIME Type Editor")
do_screenshot("xfce4-mouse-settings", "Mouse and Touchpad")
do_screenshot("xfce4-settings-manager", "Settings")


import psutil
PROCNAME = "xfce4-appfinder"

for proc in psutil.process_iter():
  # check whether the process name matches
  if proc.name() == PROCNAME:
    proc.kill()
