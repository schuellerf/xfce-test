#!/usr/bin/env python

import ldtp as l
import re
import cv2

img_name = l.imagecapture()

wins=l.getwindowlist()

re_pattern = r"(.*)auto([0-9]+)auto(.*)"

for w in wins:
    obj = l.getobjectlist(w)
    for o in obj:
        info = l.getobjectinfo(w,o)
        if 'label' in info:
            label = l.getobjectproperty(w,o,'label')
            print(w,o)
            m = re.search(re_pattern, label)
            if m:
                id_num = m.group(2)
                size = l.getobjectsize(w,o)
                if size[0] > 0:
                    print("Translation #{} is here: ('{}','{}')".format(id_num, re.sub(re_pattern,"\\1\\3",w), re.sub(re_pattern,"\\1\\3",o)))
                    print("Located in picture: {}".format(size))
                    img = cv2.imread(img_name)
                    new_img = cv2.rectangle(img, (size[0], size[1]), (size[0] + size[2], size[1] + size[3]), (0,0,255), 3)
                    cv2.imwrite('/tmp/translation_{}_{}.png'.format(id_num, o), new_img)


