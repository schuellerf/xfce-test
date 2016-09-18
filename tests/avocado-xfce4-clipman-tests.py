#!/usr/bin/env python

import sys
import xmlrpclib
import time
from avocado import Test

class XFCE4_clipman(Test):

	def __init__(self, methodName='test', name=None, params=None,
               base_logdir=None, job=None, runner_queue=None):
		super(XFCE4_clipman, self).__init__(methodName, name, params,
                                               base_logdir, job,
                                               runner_queue)
		self.p=xmlrpclib.ServerProxy("http://localhost:4118")

	def test_all_is_empty(self):
		self.p.launchapp("xfce4-clipman")
		self.p.launchapp("xfce4-popup-clipman")
		self.assertTrue(self.p.waittillguiexist("dlg0","mnuClipboardisempty")==1)
		self.p.generatekeyevent('<esc>')
		self.assertTrue(self.p.waittillguinotexist("dlg0")==1)

