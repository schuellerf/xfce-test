#!/usr/bin/env python

import sys
import ldtp
import time
from avocado import Test

class XFCE4_clipman(Test):

	def __init__(self, methodName='test', name=None, params=None,
               base_logdir=None, job=None, runner_queue=None):
		super(XFCE4_clipman, self).__init__(methodName, name, params,
                                               base_logdir, job,
                                               runner_queue)

        def _startApp(self, app):
            """ start and assure running """
            ldtp.launchapp(app)
            while True:
                l = ldtp.getapplist()
                print(l)
                if app in l:
                    break
                time.sleep(0.1)

	def test_all_is_empty(self):
		# Catching some I/O error on the very first application start in the container
		ldtp.launchapp("xfce4-terminal")
		time.sleep(1)
		#self.assertFalse("xfce4-terminal" in ldtp.getapplist(), "The initial I/O error is gone?")
		if "xfce4-terminal" in ldtp.getapplist():
			ldtp.generatekeyevent('<alt><f4>')

		self._startApp("xfce4-clipman")

		ldtp.launchapp("xfce4-popup-clipman")

		self.assertTrue(ldtp.waittillguiexist("dlg0","mnuClipboardisempty")==1, "The popup menu did not show up")
		ldtp.generatekeyevent('<esc>')
		self.assertTrue(ldtp.waittillguinotexist("dlg0")==1, "The popup menu didn't disappear")

	def test_first_copy(self):
		# some app to type into
                self._startApp("xfce4-appfinder")

		#type something
		ldtp.generatekeyevent('Test-text1')

		ldtp.generatekeyevent("<ctrl>a")

		# selection is ignored in the default configuration
		ldtp.launchapp("xfce4-popup-clipman")
		self.assertTrue(ldtp.waittillguiexist("dlg0","mnuClipboardisempty")==1, "The empty popup menu did not show up")
		ldtp.generatekeyevent('<esc>')
		self.assertTrue(ldtp.waittillguinotexist("dlg0")==1, "The empty popup menu didn't disappear")

		# now really copy
		ldtp.generatekeyevent('<ctrl>c')

		# check if it's in the list
		ldtp.launchapp("xfce4-popup-clipman")
		self.assertTrue(ldtp.waittillguiexist("dlg0","mnuTest-text1")==1, "The filled popup menu did not show up")
		ldtp.generatekeyevent('<esc>')
		self.assertTrue(ldtp.waittillguinotexist("dlg0")==1, "The filled popup menu didn't disappear")

		ldtp.generatekeyevent('<esc>')

		self.assertTrue(ldtp.waittillguinotexist("frmApplicationFinder")==1, "App-Finder didn't close...")

