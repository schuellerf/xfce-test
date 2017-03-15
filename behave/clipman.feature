Feature: Some tests with clipman

  Scenario: Clipman doesn't always start on the first try?
     Given we just start xfce4-clipman
      when we kill xfce4-clipman
      then we make a short break
       and we don't expect anything

  Scenario: There seems to be a bug when we don't do _anything_
     Given nothing
      when we wiggle the mouse
      then we don't expect anything

  Scenario: Just open clipman popup
     Given we have xfce4-clipman started
      when we popup clipman
      then we should see dlg0
       and we make a short break
       and close it with <esc>

  Scenario: Copy something
     Given we have xfce4-clipman started
       and we just start xfce4-appfinder
      when we type "ExampleText"
       and we type "<ctrl>a"
       and we type "<ctrl>c"
       and we type "<esc>"
       and we popup clipman
      then we should see mnuExampleText in dlg0
       and close it with <esc>

  Scenario: enable selection copy
     Given we have xfce4-clipman started
       and we have xfce4-clipman-settings started
      when we click on chkIgnoreselections in dlgClipman
       and we click on btnClose in dlgClipman
      then dlgClipman is gone

  Scenario: Clear clipman list
     Given we have xfce4-clipman started
       and clipman list is not empty
      when we popup clipman
       and we click on mnuClearhistory in dlg0
       and we click on btnYes in dlgQuestion
       and we popup clipman
      then we should see mnuClipboardisempty in dlg0
       and close it with <esc>
       and we make a short break

  Scenario: There was no clipman before _we_ started...
     Given nothing
      when we kill xfce4-clipman
      then we don't expect anything

