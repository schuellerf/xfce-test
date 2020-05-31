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

@given(u'we repeat "{scenario}" in language {lang}')
def step_impl(context, scenario, lang):
    context._root['my_lang'] = lang
    context.execute_steps(_get_scenario(context, scenario))

# ---- when
@when('we click on {thing} in {win}')
def step_impl(context, thing, win):
    lang = context._root.get('my_lang', None)
    indexes = context._root.get('obj_indexes', {})

    my_id = f"we click on {thing} in {win}"
    print(my_id)
    if lang is None:
        # save indexes for later
        l.waittillguiexist(win)
        indexes[my_id] = (l.getwindowlist().index(win), l.getobjectlist(win).index(thing))
        context._root["obj_indexes"] = indexes
    else:
        
        print(f"Override {win} and {thing} with")
        (w_idx, o_idx) = indexes[my_id]
        print(f"  ids {w_idx} and {o_idx} to")
        # just wait until we have at least enough windows
        i = 0
        while len(l.getwindowlist()) <= w_idx:
            time.sleep(0.1)
            i = i + 1
            if i > 20:
                break
        win = l.getwindowlist()[w_idx]
        thing = l.getobjectlist(win)[o_idx]
        print(f"  to {win} and {thing}")
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
