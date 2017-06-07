DEBUG_ON_ERROR = False

import os
import ldtp as l

def before_scenario(context, scenario):
    """ saves all scenarios for later use
    """
    if "all_my_scenarios" not in context._root:
        context._root["all_my_scenarios"] = {}
    context._root["all_my_scenarios"][scenario.name.lower()] = scenario.all_steps

def setup_debug_on_error(userdata):
    global DEBUG_ON_ERROR
    DEBUG_ON_ERROR = userdata.getbool("DEBUG_ON_ERROR")

def before_all(context):
    setup_debug_on_error(context.config.userdata)

def after_step(context, step):
    if os.environ.get("SCREENSHOTS") == "ALWAYS":
        directory=os.path.join(os.path.abspath(os.curdir),"Screenshots",context._stack[1]["feature"].name, 
                  "{}_{}_{}".format(context._stack[0]["scenario"].filename.replace(".feature",""), context._stack[0]["scenario"].line, context._stack[0]["scenario"].name))

        if not os.path.exists(directory):
            os.makedirs(directory)

        filename=os.path.join(directory, "{}_{}_{}_{}.png".format( step.filename.replace(".feature",""),step.line, step.step_type, step.name))
        l.imagecapture(None,filename)

    if DEBUG_ON_ERROR and step.status == "failed":
        # -- ENTER DEBUGGER: Zoom in on failure location.
        import pdb
        pdb.set_trace()
