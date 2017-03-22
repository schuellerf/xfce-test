def before_scenario(context, scenario):
    """ saves all scenarios for later use
    """
    if "all_my_scenarios" not in context._root:
        context._root["all_my_scenarios"] = {}
    context._root["all_my_scenarios"][scenario.name.lower()] = scenario.all_steps
