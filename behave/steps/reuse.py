import behave
import ldtp as l
import time
import math
import re
import cv2
import os

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
    
OUTPUT_DIR=os.environ.get("OUTPUT_DIR", "/data/lang-screenshots")

@when('we now inspect {win}')
def step_impl(context, win):
    lang = context._root.get('my_lang', None)
    w_o_mapping = context._root.get('w_o_mapping', {})
    feature = context._stack[1]["feature"].filename
    line = context._root["my_line"]
    po_map = context._root.get('po_map', {})
    locator_map = context._root.get('locator_map', {})
    
    (win, _) = _resolveNames(context, win)

    # _resolveNames() already saved the indexes - we can quit now
    if lang is None:
        return

    img_name = l.imagecapture()

    re_pattern = r"(.*)auto([0-9]+)auto(.*)"
    time.sleep(1)
    obj = l.getobjectlist(win)
    w_clean = re.sub(re_pattern,"\\1\\3",win)

    # avoiding multiple appearances with the same filename
    multi_appear = {}
    for o in obj:
        print(f"Get info for {o}")
        info = l.getobjectinfo(win,o)
        o_clean = re.sub(re_pattern,"\\1\\3",o)
        # "or o_clean" means that the pattern can be applied
        if 'label' in info or o_clean:
            if 'label' in info:
                print("Get real label")
                label = l.getobjectproperty(win,o,'label')
            else:
                print("Use object as label")
                label = o
            print(f"   label: {label}")
            size = None
            if label is None:
                print("label is none")
                continue


            try:
                size = l.getobjectsize(win,o)
                if size[0] < 0:
                    size = None
            except Exception as e:
                print(e)
                size = None
            # check if we find the "automate language"
            m = re.search(re_pattern, label)
            if m:
                print(f"Found automate here: {label}")
                id_num = m.group(2)
                if size:
                    # store "translation ID" (i.e. po-line number) for later
                    w_o_mapping[(w_clean, o_clean, line)] = id_num
                    print("Translation #{} is here: ('{}','{}')".format(id_num, w_clean, o_clean))
                    print("Located in picture: {}".format(size))

            # or check if we already know the translation from the "automate language"-run
            elif (win, o, line) in w_o_mapping.keys():
                print(f"Found mapping: {label}")
                id_num = w_o_mapping[(win, o, line)]
                if size:
                    print("Found translation #{}".format(id_num))

                    # SMELL: move to feature function and execute only once
                    if not os.path.exists(OUTPUT_DIR):
                        os.makedirs(OUTPUT_DIR)
                    img = cv2.imread(img_name)
                    x = size[0]
                    y = size[1]
                    w = size[2]
                    h = size[3]
                    new_img = cv2.rectangle(img, (x, y), (x + w, y + h), (0,0,255), 3)
                    timestamp = int(time.time())
                    filename = f"{feature}_{lang}_po{id_num}_featureline_{line}_{timestamp}"
                    # for multiple ocurrances of one translation in the same window and same step
                    multi_appear[filename] = multi_appear.get(filename, 0) + 1
                    filename=f"{filename}_{multi_appear[filename]}.png"
                    cv2.imwrite(os.path.join(OUTPUT_DIR,filename), new_img)

                    if timestamp not in locator_map:
                        locator_map[timestamp] = []

                    locator_map[timestamp].append({"x": x, "y": y, "w": w, "h": h, "timestamp": timestamp, "name": f"PO{id_num}", "filename": filename})

            else:
                print("Neither Automate nor mapping")
    context._root["w_o_mapping"] = w_o_mapping
    context._root["locator_map"] = locator_map
