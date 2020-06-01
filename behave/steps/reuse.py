import behave
import ldtp as l
import time
import math
import re
import cv2

def _resolveNames(context, win, thing = None, ignoreErrors = False):
    """ resolve Label names, as they are called differently once translated
    that should not be necessary if the GUI items have a name set
    """
    lang = context._root.get('my_lang', None)
    indexes = context._root.get('obj_indexes', {})

    feature = context._stack[1]["feature"].filename
    line = context._root["my_line"]
    my_id = f"{feature}_{line}"
    print(f"For {my_id}")
    print(l.getwindowlist())
    if lang is None:
        # save indexes for later
        l.waittillguiexist(win)
        try:
            o_idx = l.getobjectlist(win).index(thing) if thing else None
        except:
            o_idx = None
        indexes[my_id] = (l.getwindowlist().index(win), o_idx)
        context._root["obj_indexes"] = indexes
        print("Saving index")
    else:

        print(f"Override {win} and {thing} with")
        (w_idx, o_idx) = indexes[my_id]
        print(f"  ids {w_idx} and {o_idx}")
        # just wait until we have at least enough windows
        i = 0
        while len(l.getwindowlist()) <= w_idx:
            time.sleep(0.1)
            i = i + 1
            if i > 20:
                break
        window_list = l.getwindowlist()

        # if the window now has a translated name, trying
        # to get it by "last-seen-index"
        if win not in window_list:
            try:
                win_new = window_list[w_idx]
                if not ignoreErrors: assert win[0:3] == win_new[0:3], f"I don't think that {win} is now called {win_new} ..."
                win = win_new
            except:
                if not ignoreErrors: raise
        else:
            print("found the window, nice!")
        # if the thing now has a translated name, trying
        # to get it by "last-seen-index"
        if thing is not None:
            object_list = l.getobjectlist(win)
            print(object_list)
            if thing not in object_list:
                try:
                    thing_new = object_list[o_idx]
                    if not ignoreErrors: assert thing[0:3] == thing_new[0:3], f"I don't think that {thing} is now called {thing_new} ..."
                    thing = thing_new
                except:
                    if not ignoreErrors: raise
            else:
                print("found the thing, nice!")

        print(f"  to {win} and {thing}")
        l.waittillguiexist(win)
    return (win, thing)

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

    (win, thing) = _resolveNames(context, win, thing)

    (x,y,w,h)=l.getobjectsize(win, thing)
    click_x = x+(w/2)
    click_y = y+(h/2)
    print(f"Clicking {click_x}/{click_y} in {x}/{y}+{w}/{h}")
    if click_x < 0 or click_y < 0:
        print(f"I'd rather not click {click_x}/{click_y}")
        print(f"failed to click {thing} in {l.getobjectlist(win)}")
        return
        # assert click_x > 0, f"I'd rather not click {click_x}/{click_y}"
        # assert click_y > 0, f"I'd rather not click {click_x}/{click_y}"
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
    print(f"Clicking {click_x}/{click_y} in {x}/{y}+{w}/{h}")
    if click_x < 0 or click_y < 0:
        print(f"I'd rather not click {click_x}/{click_y}")
        print(f"failed to click {thing} in {l.getobjectlist(win)}")
        return
        # assert click_x > 0, f"I'd rather not click {click_x}/{click_y}"
        # assert click_y > 0, f"I'd rather not click {click_x}/{click_y}"
    context._root["_click_animated"](context, click_x, click_y)
    
OUTPUT_DIR="/data/lang-screenshots"
    
@when('we now inspect {win}')
def step_impl(context, win):
    lang = context._root.get('my_lang', None)
    w_o_mapping = context._root.get('w_o_mapping', {})
    feature = context._stack[1]["feature"].filename
    line = context._root["my_line"]
    
    (win, _) = _resolveNames(context, win)

    # _resolveNames() already saved the indexes - we can quit now
    if lang is None:
        return

    img_name = l.imagecapture()

    re_pattern = r"(.*)auto([0-9]+)auto(.*)"

    obj = l.getobjectlist(win)
    w_clean = re.sub(re_pattern,"\\1\\3",win)

    # avoiding multiple appearances with the same filename
    multi_appear = {}
    for o in obj:
        print(f"Get info for {o}")
        info = l.getobjectinfo(win,o)
        o_clean = re.sub(re_pattern,"\\1\\3",o)
        if 'label' in info:
            print("Get label")
            label = l.getobjectproperty(win,o,'label')
            size = None
            if label is None:
                continue

            # check if we find the "automate language"
            m = re.search(re_pattern, label)
            if m:
                id_num = m.group(2)
                try:
                    size = l.getobjectsize(win,o)
                    if size[0] > 0:
                        w_o_mapping[(w_clean, o_clean)] = id_num
                        print("Translation #{} is here: ('{}','{}')".format(id_num, w_clean, o_clean))
                        print("Located in picture: {}".format(size))
                except Exception as e:
                    print(e)

            # or check if we already know the translation from the "automate language"-run
            elif (win, o) in w_o_mapping.keys():
                id_num = w_o_mapping[(win, o)]
                try:
                    size = l.getobjectsize(win,o)
                    if size[0] > 0:
                        print("Found translation #{}".format(id_num))
                    else:
                        size = None
                except Exception as e:
                    print(e)
                    size = None

                # in both cases we want a screenshot
                if size:
                    img = cv2.imread(img_name)
                    new_img = cv2.rectangle(img, (size[0], size[1]), (size[0] + size[2], size[1] + size[3]), (0,0,255), 3)
                    filename = f"{OUTPUT_DIR}/{feature}_{line}-{lang}_po{id_num}"
                    multi_appear[filename] = multi_appear.get(filename, 0) + 1
                    cv2.imwrite(f"{filename}_{multi_appear[filename]}.png", new_img)
    context._root["w_o_mapping"] = w_o_mapping