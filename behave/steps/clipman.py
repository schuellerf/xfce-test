from behave import *
import ldtp as l
import time
import os
import subprocess, signal

def app_is_in_ps(app):
    p = subprocess.Popen(['ps', '-A'], stdout=subprocess.PIPE)
    out, err = p.communicate()
    for line in out.splitlines():
        if (app in line) and ("defunct" not in line):
            #pid = int(line.split(None, 1)[0])
            return True
    return False

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
    applist = _getapplist()
    if app not in applist:
        if len(applist) == 0 and app_is_in_ps(app):
            #grrrr why doesn't ldtp find the app!?
            return
        l.launchapp(app)
        while True:
            retry -= 1
            assert(retry > 0)#, "Failed to start " + app)
            applist = _getapplist()
            if app in applist:
                time.sleep(1)
                break
            time.sleep(0.5)

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

@given('we find {popupwin} which has {entry} by stupid-clicking {win}')
def step_impl(context, popupwin, entry, win):
    click_those = l.getobjectlist(win)
    for thing in click_those:
        l.mouserightclick(win, thing)
        if l.waittillguiexist(popupwin, entry, 1): return
        l.generatekeyevent("<esc>") #close possible menus
        time.sleep(0.5)
    #not found
    assert(False)

# ---- when
@when('we popup clipman')
def step_impl(context):
    l.launchapp("xfce4-popup-clipman")
    time.sleep(1) # he doesn't wait for the popup

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

@when('we make a short break')
def step_impl(context):
    time.sleep(1)

@when('we make a longer break')
def step_impl(context):
    time.sleep(5)


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

@then("we think {checkbox} of {win} is {state}")
def step_impl(context, checkbox, win, state):
    check = False
    if state.lower() in ["checked", "true", "enabled"]:
        check = True
    if check:
        assert(l.verifycheck(win, checkbox))
    else:
        assert(l.verifyuncheck(win, checkbox))

