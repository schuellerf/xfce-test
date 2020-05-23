import behave
import ldtp as l
import time
import math

def _reTextify(thing):
    """ return text of step or scenario as if it was
        in a feature file
    """
    if type(thing) is behave.model.Scenario:
        return unicode(thing.name)
    if type(thing) is behave.model.Step:
        return u"{0} {1}".format(thing.step_type,thing.name)
    raise NotImplementedError(u'I don\'t know how to _reTextify ' + str(type(thing)))

def _get_scenario(context, scenario):
    """ return string representation of given scenario
    """
    ret = ""
    for step in context._root["all_my_scenarios"][scenario.lower()]:
        ret += _reTextify(step) + u"\n"
    return ret

# ---- given
@given(u'we repeat "{scenario}"')
def step_impl(context, scenario):
    context.execute_steps(_get_scenario(context, scenario))

# ---- when
@when('we click on {thing} in {win}')
def step_impl(context, thing, win):
    l.waittillguiexist(win)
    (x,y,w,h)=l.getobjectsize(win, thing)
    click_x = x+(w/2)
    click_y = y+(h/2)
    context._root["_click_animated"](context, click_x, click_y)

@when('we click on {thing} somewhere')
def step_impl(context, thing):
    time.sleep(1)
    win = None
    for w in l.getwindowlist():
        objs = l.getobjectlist(w)
        if thing in objs:
            win = w
            break
    if not win:
        print(f"Failed to find {thing}")
        return
    print("Parent:")
    print(l.getobjectproperty(win,thing,'parent'))
    (x,y,w,h)=l.getobjectsize(win, thing)
    click_x = x+(w/2)
    click_y = y+(h/2)
    context._root["_click_animated"](context, click_x, click_y)
