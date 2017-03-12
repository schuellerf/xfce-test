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

        def _startApp(self, app):
            """ start and assure running """
            self.p.launchapp(app)
            while True:
                l = self.p.getapplist()
                print(l)
                if app in l:
                    break
                time.sleep(0.1)

	def test_all_is_empty(self):
		# Catching some I/O error on the very first application start in the container
		self.p.launchapp("xfce4-terminal")
		time.sleep(1)
		self.assertFalse("xfce4-terminal" in self.p.getapplist(), "The initial I/O error is gone?")

		self._startApp("xfce4-clipman")

		self.p.launchapp("xfce4-popup-clipman")

		self.assertTrue(self.p.waittillguiexist("dlg0","mnuClipboardisempty")==1, "The popup menu did not show up")
		self.p.generatekeyevent('<esc>')
		self.assertTrue(self.p.waittillguinotexist("dlg0")==1, "The popup menu didn't disappear")

	def test_first_copy(self):
		# some app to type into
                self._startApp("xfce4-terminal")

		#type something
		self.p.generatekeyevent('Test-text1')

		(x,y,w,h) = self.p.getwindowsize('frmTerminal')

		# TBD find the correct text to double click and copy
		self.p.generatemouseevent(x+w/3,y+70, 'b1d')

		# selection is ignored in the default configuration
		self.p.launchapp("xfce4-popup-clipman")
		self.assertTrue(self.p.waittillguiexist("dlg0","mnuClipboardisempty")==1, "The popup menu did not show up")
		self.p.generatekeyevent('<esc>')

		# now really copy
		self.p.generatekeyevent('<ctrl><shift>c')

		# check if it's in the list
		self.p.launchapp("xfce4-popup-clipman")
		self.assertTrue(self.p.waittillguiexist("dlg0","mnuTest-text1")==1, "The popup menu did not show up")
		self.p.generatekeyevent('<esc>')
		self.assertTrue(self.p.waittillguinotexist("dlg0")==1, "The popup menu didn't disappear")

		self.p.generatekeyevent('<ctrl>c')
		self.p.generatekeyevent('<alt><f4>')

		self.assertTrue(self.p.waittillguinotexist("frmTerminal")==1, "Terminal didn't close with ALT-F4")

