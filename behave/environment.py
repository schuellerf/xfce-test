DEBUG_ON_ERROR = False

import os
import ldtp as l
import signal
import time
import math
import json

def handler(signum, frame):
    print("Time is over!")
    raise Exception("It's time to fix those LDTP bugs!")

def before_scenario(context, scenario):
    """ saves all scenarios for later use
    """
    if "all_my_scenarios" not in context._root:
        context._root["all_my_scenarios"] = {}
    context._root["all_my_scenarios"][scenario.name.lower()] = scenario.all_steps
    signal.signal(signal.SIGALRM, handler)
    signal.alarm(0)

def setup_debug_on_error(userdata):
    global DEBUG_ON_ERROR
    DEBUG_ON_ERROR = userdata.getbool("DEBUG_ON_ERROR")

def before_all(context):
    setup_debug_on_error(context.config.userdata)
    context._root["_click_animated"] = _click_animated

def _click_animated(context, click_x, click_y, button="b1c", delay=1, timing=None):
    start_x=context._root.get('last_mouse_x',0)
    start_y=context._root.get('last_mouse_y',0)

    try:
        if timing is None:
            timing=1/math.sqrt(math.pow(math.fabs(start_x-click_x),2)+math.pow(math.fabs(start_y-click_y),2))
    except:
        timing = 0.01
    
    l.simulatemousemove(start_x, start_y, click_x, click_y, timing)
    time.sleep(delay)
    l.generatemouseevent(click_x,click_y, button)
    context._root['last_mouse_x']=click_x
    context._root['last_mouse_y']=click_y
    time.sleep(delay) #clicking usually needs a task switch to some UI thread to process it

def before_step(context, step):
    # workaround for LDTP problems
    context._root["my_line"] = step.line
    signal.alarm(120)

def after_step(context, step):
    if os.environ.get("SCREENSHOTS") == "ALWAYS":
        directory=os.path.join(os.path.abspath(os.curdir),"Screenshots",context._stack[1]["feature"].name, 
                  "{}_{}_{}".format(context._stack[0]["scenario"].filename.replace(".feature",""), context._stack[0]["scenario"].line, context._stack[0]["scenario"].name))

        if not os.path.exists(directory):
            os.makedirs(directory)

        filename=os.path.join(directory, "{}_{}_{}_{}.png".format( step.filename.replace(".feature",""),step.line, step.step_type, step.name))
        l.imagecapture(None,filename)

    if DEBUG_ON_ERROR and step.status == "failed" and os.environ.get("TRAVIS") != "true":
        # -- ENTER DEBUGGER: Zoom in on failure location.
        import pdb
        pdb.set_trace()
    signal.alarm(0)
    

def after_feature(context, feature):

    locator_map = context._root.get('locator_map', {})
    OUTPUT_DIR=os.environ.get("OUTPUT_DIR", "/data/lang-screenshots")


    if len(locator_map) > 0:
        #video_file = os.environ['VIDEO_FILE']
        #po_file = os.environ['PO_FILE']
        #with open(os.path.join(OUTPUT_DIR,f"{feature.filename}.json"), 'w') as out_file:
        with open(os.path.join(OUTPUT_DIR,"data.json"), 'w') as out_file:
            out_file.write("let translations_json = '")
            out_file.write(json.dumps(locator_map))
            out_file.write("';\n")
            out_file.write("let translations = JSON.parse(translations_json);")
