#!/usr/bin/env python

import ldtp as l
import re
import cv2
import subprocess as s
import os
import time

LANG = "en_GB"
APP = ["xfce4-display-settings"]
OUTPUT_DIR="/data/lang-screenshots"

if not os.path.exists(OUTPUT_DIR):
    os.makedirs(OUTPUT_DIR)

# maps translation to window/object (currently unused)
translation = {}

# maps window/object to translation
w_o_mapping = {}

def capture_translations(app="app",lang="unknown"):


    wins1=l.getwindowlist()
    time.sleep(2) # sometimes the window is not ready yet
    wins=l.getwindowlist()

    img_name = l.imagecapture()

    re_pattern = r"(.*)auto([0-9]+)auto(.*)"

    for w in wins:
        obj = l.getobjectlist(w)
        w_clean = re.sub(re_pattern,"\\1\\3",w)
        for o in obj:
            info = l.getobjectinfo(w,o)
            o_clean = re.sub(re_pattern,"\\1\\3",o)
            if 'label' in info:
                label = l.getobjectproperty(w,o,'label')
                size = None

                # check if we find the "automate language"
                m = re.search(re_pattern, label)
                if m:
                    id_num = m.group(2)
                    size = l.getobjectsize(w,o)
                    if size[0] > 0:
                        translation[id_num] = (w_clean, o_clean)
                        w_o_mapping[(w_clean, o_clean)] = id_num
                        print("Translation #{} is here: ('{}','{}')".format(id_num, w_clean, o_clean))
                        print("Located in picture: {}".format(size))
                    else:
                        size = None

                # or check if we already know the translation from the "automate language"-run
                elif (w, o) in w_o_mapping.keys():
                    id_num = w_o_mapping[(w, o)]
                    size = l.getobjectsize(w,o)
                    if size[0] > 0:
                        print("Found translation #{}".format(id_num))
                    else:
                        size = None

                # in both cases we want a screenshot
                if size:
                    img = cv2.imread(img_name)
                    new_img = cv2.rectangle(img, (size[0], size[1]), (size[0] + size[2], size[1] + size[3]), (0,0,255), 3)
                    cv2.imwrite('{}/translation_{}_{}_{}_{}.png'.format(OUTPUT_DIR, app, lang, id_num, o), new_img)


env = os.environ

print("Starting \"automate\" run...")

env["LANG"] = "automate"

automate_process = s.Popen(APP, shell=True, env=env)

capture_translations(APP[0], "automate")

l.generatekeyevent("<alt><f4>")

time.sleep(3) # give the app a chance

automate_process.terminate() # ok then, time is up

automate_process.wait()

print(translation)
print(w_o_mapping)

print("Starting {} run...".format(LANG))
env["LANG"] = LANG
lang_process = s.Popen(APP, shell=True, env=env)
capture_translations(APP[0], LANG)
l.generatekeyevent("<alt><f4>")
time.sleep(3) # give the app a chance
lang_process.terminate() # ok then, time is up
lang_process.wait()
