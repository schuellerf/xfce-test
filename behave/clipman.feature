Feature: Some tests with clipman

  Scenario: Clipman doesn't always start on the first try?
     Given we just start xfce4-clipman
      when we kill xfce4-clipman
      then we don't expect anything

  Scenario: There seems to be a bug when we don't do _anything_
     Given nothing
      when we wiggle the mouse
      then we don't expect anything

  Scenario: Clipman popup is empty
     Given we have xfce4-clipman started
      when we popup clipman
      then we should see mnuClipboardisempty in dlg0
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

  Scenario: Clipman popup is not empty
     Given we have xfce4-clipman started
      when we popup clipman
      then we should not see mnuClipboardisempty in dlg0
       and we make a short break
       and close it with <esc>

  Scenario: enable selection copy
     Given we have xfce4-clipman started
       and we have xfce4-clipman-settings started
      when we click on ptabHistory in dlgClipmanSettings
       and we click on chkIgnoremouseselections in dlgClipmanSettings
      then we think chkIgnoremouseselections of dlgClipmanSettings is unchecked
      when we click on btnClose in dlgClipmanSettings
      then dlgClipmanSettings is gone

  Scenario: Clear clipman list
     Given we repeat "Clipman popup is not empty"
      when we popup clipman
       and we click on mnuClearhistory in dlg0
       and we click on btnYes in dlgQuestion
       and we popup clipman
      then we should see mnuClipboardisempty in dlg0
       and close it with <esc>

  Scenario: Just selecting now also copies
     Given we have xfce4-clipman started
       and we just start xfce4-appfinder
      when we type "ExampleText"
       and we type "<ctrl>a"
       and we make a short break
       and we type "<esc>"
       and we popup clipman
      then we should see mnuExampleText in dlg0
       and close it with <esc>

  Scenario: Should be saved
     Given we find dlg0 which has mnuQuit by stupid-clicking frm0
      when we click on mnuQuit in dlg0
      then dlg0 is gone

  Scenario: Text should be here after re-starting
     Given we have xfce4-clipman started
      when we popup clipman
      then we should see mnuExampleText in dlg0
       and close it with <esc>

  Scenario: There was no clipman before _we_ started...
     Given nothing
      when we kill xfce4-clipman
      then we don't expect anything
