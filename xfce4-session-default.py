#!/usr/bin/env python

import sys
import xmlrpclib
import time

#determine when ldtp and first question about default config is available???
time.sleep (5)


p=xmlrpclib.ServerProxy("http://" + sys.argv[1] + ":4118")
p.keypress("<alt>")
p.generatekeyevent("<tab>")
p.keyrelease("<alt>")
p.generatekeyevent("<enter>")

