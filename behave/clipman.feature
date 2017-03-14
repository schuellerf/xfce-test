Feature: Some tests with clipman

  Scenario: Just open clipman popup
     Given we have xfce4-clipman started
      when we popup clipman
      then we should see dlg0
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

  Scenario: Clear clipman list
     Given we have xfce4-clipman started
       and clipman list is not empty
      when we popup clipman
       and click on mnuClearhistory in dlg0
       and click on btnYes in dlgQuestion
       and we popup clipman
      then we should see mnuClipboardisempty in dlg0
       and close it with <esc>
