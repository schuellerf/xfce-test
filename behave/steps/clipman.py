from behave import *
import ldtp as l
import time
import os

def _getapplist():
    """ just l.getapplist() but without exceptions
    """
    try:
        return l.getapplist()
    except:
        return []

# ---- given
@given('we have {app:S} started')
def step_impl(context, app):
    retry = 100
    
    if app not in _getapplist():
        l.launchapp(app)
        while True:
            retry -= 1
            assert(retry > 0)#, "Failed to start " + app)
            applist = _getapplist()
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

@given('nothing')
def step_impl(context):
    pass

# ---- when
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

@when('we wiggle the mouse')
def step_impl(context):
    l.simulatemousemove(0,0,100,100)
    l.generatemouseevent(200,200) # There shouldn't be anything

@when('we kill {app}')
def step_impl(context, app):
    time.sleep(2)
    os.system("killall -9 " + app)

# ---- then
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

@then("we don't expect anything")
def step_impl(context):
    assert(True)

