@fixture.startXFCE4Clipman
Feature: For translations: Make all texts visible

  # Using only one scenario here, just because "quit" by "stupid-clicking" should not be done more often
  Scenario Outline: Translate Clipman
     Given we have xfce4-clipman started in <lang>

     Given we find dlg1 which has mnuQuit by stupid-clicking frm0
      when we now inspect dlg1
      when we click on mnuAbout somewhere
      when we now inspect dlgAboutClipman
       and we click on rbtnCredits in dlgAboutClipman
      when we now inspect dlgAboutClipman
       and we click on rbtnLicense in dlgAboutClipman
      when we now inspect dlgAboutClipman
      then close it with <esc>

      when we popup clipman
      when we now inspect dlg1
      then close it with <esc>

     Given we have xfce4-clipman-settings started in <lang>
      when we now inspect dlgClipmanSettings
       and we click on ptabActions in dlgClipmanSettings
      when we now inspect dlgClipmanSettings
       and we click on btn0 in dlgClipmanSettings
      when we now inspect dlgEditAction
       and we click on btn0 in dlgEditAction
      when we now inspect dlgRegularexpression
       and we click on btnCancel in dlgRegularexpression
       and we click on btnCancel in dlgEditAction
       and we click on ptabHistory in dlgClipmanSettings
      when we now inspect dlgClipmanSettings
       and we click on btnClose in dlgClipmanSettings

     Given we find dlg1 which has mnuQuit by stupid-clicking frm0
      when we click on mnuQuit somewhere
      then dlg1 is gone
   Examples: Languages
     | lang             |
     | C                |
     | automate         |
     | TRANSLATION_LANG |

# we have to do it three times as the dialog names as referenced from the behave test are in english and
# even behave won't work if we can't find the dialogs in the test
# the framework remembers facts about the dialogs in the test for the "automate language" and "language" run itself