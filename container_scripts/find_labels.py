#!/usr/bin/env python

import ldtp as l
import re
import cv2

img_name = l.imagecapture()

wins=l.getwindowlist()


for w in wins:
    obj = l.getobjectlist(w)
    for o in obj:
        info = l.getobjectinfo(w,o)
        if 'label' in info:
            label = l.getobjectproperty(w,o,'label')
            m = re.search("auto([0-9]+)auto", label)
            if m:
                size = l.getobjectsize(w,o)
                if size[0] > 0:
                    print("Translation #{} is here: ('{}','{}')".format(m.group(1), w, o))
                    print("Located in picture: {}".format(size))
                    img = cv2.imread(img_name)
                    new_img = cv2.rectangle(img, (size[0], size[1]), (size[0] + size[2], size[1] + size[3]), (0,0,255), 3)
                    cv2.imwrite('/tmp/translation_{}_{}.png'.format(m.group(1), o), new_img)


