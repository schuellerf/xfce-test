from behave import *
import ldtp as l
import time

@given('we have {app:S} started')
def step_impl(context, app):
    retry = 100
    if app not in l.getapplist():
        l.launchapp(app)
        while True:
            retry -= 0
            if retry == 0: fail("Failed to start " + app)
            applist = l.getapplist()
            if app in applist:
                break
            time.sleep(0.1)

#just for apps which can't be really detected
@given('we just start {app:S}')
def step_impl(context, app):
    l.launchapp(app)
    time.sleep(1)

@given('clipman list is not empty')
def step_impl(context):
    l.launchapp("xfce4-popup-clipman")
    assert(l.waittillguinotexist("dlg0","mnuClipboardisempty")==1)
    l.generatekeyevent("<esc>")

@when('we popup clipman')
def step_impl(context):
    l.launchapp("xfce4-popup-clipman")

@when('we see {thing:S}')
def step_impl(context, thing):
    assert(l.waittillguiexist(thing) == 1)

@when('we click on {thing} in {win}')
def step_impl(context, thing, win):
    l.waittillguiexist(win)
    l.mouseleftclick(win,thing)

@when('we type "{text}"')
def step_impl(context, text):
    l.generatekeyevent(text)

@then('we should see {thing:S}')
def step_impl(context, thing):
    assert(l.waittillguiexist(thing) == 1)

@then('we should see {thing:S} in {win:S}')
def step_impl(context, thing, win):
    assert(l.waittillguiexist(win, thing) == 1)

@then('close it with {key}')
def step_impl(context, key):
    l.generatekeyevent(key)

@then('{win:S} is gone')
def step_impl(context, win):
    assert(l.waittillguinotexist(win) == 1)

@then('we make a short break')
def step_impl(context):
    time.sleep(1)
