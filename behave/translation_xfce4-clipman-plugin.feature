@fixture.startXFCE4Clipman
Feature: For translations: Make all texts visible

  Scenario: start clipman
     Given we have xfce4-clipman started

  Scenario: show the popup
     Given we have xfce4-clipman started
      when we popup clipman
      then close it with <esc>
       and close it with <esc>

  Scenario: go through all settings
     Given we have xfce4-clipman started
       and we have xfce4-clipman-settings started
      when we click on ptabActions in dlgClipman
       and we click on btn0 in dlgClipman
       and we click on btn0 in dlgEditAction
       and we click on btnCancel in dlgRegularexpression
       and we click on btnCancel in dlgEditAction
       and we click on ptabTweaks in dlgClipman
       and we click on btnClose in dlgClipman

  Scenario: Open right-click menu
     Given we find dlg0 which has mnuQuit by stupid-clicking frm0
      when we click on mnuAbout in dlg1
       and we click on tbtnCredits in dlgAboutClipman
       and we click on tbtnLicense in dlgAboutClipman
       and we click on btnClose in dlgAboutClipman
      then close it with <esc>
