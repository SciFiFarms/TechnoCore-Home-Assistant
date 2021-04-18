import json
import re


@service
def add_entity_to_list_var(entity=None, list_var=None):
    entities = json.loads( state.get(f'var.{ list_var }') )
    if not entities:
        entities = []

    if entity in entities:
        entities.remove(entity)
    else:
        entities = entities + [entity]

    state.set(f'var.{ list_var }', json.dumps( entities ) )
    #log.warning(f"{ entities }")

@service
def send_state_to_entities_list(list_var=None, topic=None, state_entity=None, numbers_only=False, retain=False):
    if numbers_only:
        # Remove everything lead upto and including ": " . Will allow for dynamic removal of descriptions.
        state = re.sub( ".*: ", "" , state.get( state_entity ) )
    else:
        state = state.get( state_entity )


    send_mqtt_to_entities_list(list_var, topic, state, retain)

@service
def send_mqtt_to_entities_list(list_var=None, topic=None, payload=None, retain=False):

    entities = json.loads( state.get(f'var.{ list_var }') )
    #log.warning(f"{ payload }")
    for entity in entities:
        entity = re.sub('.*\.(.*\d+).*', '\\1', entity)
        #log.warning(f"{ entity }")
        service.call("mqtt", "publish", topic=topic.replace("THIS_ENTITY", entity), payload=payload, retain=retain)

        log.warning(f"{ topic.replace('THIS_ENTITY',  entity ) }")

@service
def clear_entities_list_var(list_var=None):
    #log.warning(f"{ list_var }")
    state.set(f'var.{ list_var }',  "[]" )


