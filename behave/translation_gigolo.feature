@fixture.startGigolo
Feature: For translations: Make all texts visible

  Scenario Outline: Translate Gigolo
     Given we have gigolo started in <lang>

      when we click on mnuFile in frmGigolo
      when we now inspect frmGigolo
      then close it with <esc>
      
      when we click on mnuEdit in frmGigolo
      when we now inspect frmGigolo
      then close it with <esc>
      
      when we click on mnuView in frmGigolo
      when we now inspect frmGigolo
      then close it with <esc>

      when we click on mnuActions in frmGigolo
      when we now inspect frmGigolo
      then close it with <esc>

      when we click on mnuHelp in frmGigolo
      when we now inspect frmGigolo
      then close it with <esc>
      
       and close it with <ctrl>q

   Examples: Languages
     | lang             |
     | C                |
     | automate         |
     | TRANSLATION_LANG |

# we have to do it three times as the dialog names as referenced from the behave test are in english and
# even behave won't work if we can't find the dialogs in the test
# the framework remembers facts about the dialogs in the test for the "automate language" and "language" run itself