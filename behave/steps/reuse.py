import behave

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

@given(u'we repeat "{scenario}"')
def step_impl(context, scenario):
    context.execute_steps(_get_scenario(context, scenario))
