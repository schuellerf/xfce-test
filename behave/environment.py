DEBUG_ON_ERROR = False

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
    if DEBUG_ON_ERROR and step.status == "failed":
        # -- ENTER DEBUGGER: Zoom in on failure location.
        import pdb
        pdb.set_trace()
