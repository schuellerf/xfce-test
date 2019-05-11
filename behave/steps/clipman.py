from behave import *
import ldtp as l
import time
import os
import subprocess, signal

def handler(signum, frame):
  print "Time is over!"
  raise Exception("It's time to fix those LDTP bugs!")

def app_is_in_ps(app):
    p = subprocess.Popen(['ps', '-A'], stdout=subprocess.PIPE)
    out, err = p.communicate()
    for line in out.splitlines():
        if (app in line) and ("defunct" not in line):
            #pid = int(line.split(None, 1)[0])
            return True
    return False



# ---- given
@given('we have {app:S} started')
def step_impl(context, app):
    retry = 100
    applist = l.getapplist()
    if app not in applist:
        if len(applist) == 0 and app_is_in_ps(app):
            #grrrr why doesn't ldtp find the app!?
            print(app + " was found by ps")
            return
        print(app + " needs to be launched")
        l.launchapp(app, logfiles=("/tmp/%s-stdout.log" % app, "/tmp/%s-stderr.log" % app))
        while True:
            retry -= 1
            assert(retry > 0)#, "Failed to start " + app)
            applist = l.getapplist()
            if app in applist:
                time.sleep(1)
                print(app + " started")
                break
            time.sleep(0.5)
    else:
        print(app + " is running already")

#just for apps which can't be really detected
@given('we just start {app:S}')
def step_impl(context, app):
    l.launchapp(app, logfiles=("/tmp/%s-stdout.log" % app, "/tmp/%s-stderr.log" % app))
    time.sleep(1)

@given('nothing')
def step_impl(context):
    pass

@given('we find {popupwin} which has {entry} by stupid-clicking {win}')
def step_impl(context, popupwin, entry, win):
    click_those = l.getobjectlist(win)
    for thing in click_those:
        (x,y,w,h)=l.getobjectsize(win, thing)
        # expecting the object to consist of square shaped icons
        # so let's click in the middle of those
        click_x = x+(h/2)
        click_y = y+(h/2)
        while click_x < (x+w):
            l.generatemouseevent(click_x,click_y, "b3c")
            signal.signal(signal.SIGALRM, handler)
            signal.alarm(60)
            if l.waittillguiexist(popupwin, entry, 1): return
            signal.alarm(0)
            l.generatekeyevent("<esc>") #close possible menus
            time.sleep(0.5)
            click_x += h
    #not found
    assert(False)

# ---- when
@when('we popup clipman')
def step_impl(context):
    time.sleep(2) # this is so asynchronous...
    l.launchapp("xfce4-popup-clipman", logfiles=("/tmp/xfce4-popup-clipman-stdout.log", "/tmp/xfce4-popup-clipman-stderr.log"))
    time.sleep(1) # this doesn't work every time...?
    l.launchapp("xfce4-popup-clipman", logfiles=("/tmp/xfce4-popup-clipman-stdout.log", "/tmp/xfce4-popup-clipman-stderr.log"))
    time.sleep(1) # now we are desperate
    l.launchapp("xfce4-popup-clipman", logfiles=("/tmp/xfce4-popup-clipman-stdout.log", "/tmp/xfce4-popup-clipman-stderr.log"))
    time.sleep(2) # he doesn't wait for the popup

@when('we see {thing:S}')
def step_impl(context, thing):
    signal.signal(signal.SIGALRM, handler)
    signal.alarm(60)
    assert(l.waittillguiexist(thing) == 1)
    signal.alarm(0)

@when('we click on {thing} in {win}')
def step_impl(context, thing, win):
    signal.signal(signal.SIGALRM, handler)
    signal.alarm(60)
    l.waittillguiexist(win)
    signal.alarm(0)
    (x,y,w,h)=l.getobjectsize(win, thing)
    click_x = x+(w/2)
    click_y = y+(h/2)
    l.generatemouseevent(click_x,click_y)
    time.sleep(2) #clicking usually needs a task switch to some UI thread to process it

@when('we type "{text}"')
def step_impl(context, text):
    l.generatekeyevent(text)

@when('we wiggle the mouse')
def step_impl(context):
    l.simulatemousemove(0,0,100,100)
    l.generatemouseevent(200,200) # There shouldn't be anything

@when('we kill {app}')
def step_impl(context, app):
    time.sleep(1)
    os.system("killall -9 " + app)
    time.sleep(1) # give the OS some time to kill it

@when('we make a short break')
def step_impl(context):
    time.sleep(1)

@when('we make a longer break')
def step_impl(context):
    time.sleep(5)


# ---- then
@then('we should see {thing:S}')
def step_impl(context, thing):
    time.sleep(2) # opening usually needs a task switch to some UI thread to process it
    signal.signal(signal.SIGALRM, handler)
    signal.alarm(60)
    assert(l.waittillguiexist(thing) == 1)
    signal.alarm(0)

@then('we should see {thing:S} in {win:S}')
def step_impl(context, thing, win):
    time.sleep(2) # opening usually needs a task switch to some UI thread to process it
    signal.signal(signal.SIGALRM, handler)
    signal.alarm(60)
    assert(l.waittillguiexist(win, thing) == 1)
    signal.alarm(0)

@then('we should not see {thing:S} in {win:S}')
def step_impl(context, thing, win):
    time.sleep(2) # closing usually needs a task switch to some UI thread to process it
    assert(l.waittillguinotexist(win, thing) == 1)

@then('close it with {key}')
def step_impl(context, key):
    l.generatekeyevent(key)
    time.sleep(1) # input usually needs a task switch to some UI thread to process it

@then('{win:S} is gone')
def step_impl(context, win):
    time.sleep(2) # closing usually needs a task switch to some UI thread to process it
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

