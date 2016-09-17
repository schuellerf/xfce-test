#!/usr/bin/env python

import sys
import xmlrpclib

p=xmlrpclib.ServerProxy("http://" + sys.argv[1] + ":4118")
p.launchapp("xfce4-clipman")
p.launchapp("xfce4-clipman-settings")
p.launchapp("xfce4-popup-clipman")

