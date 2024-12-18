extends Node
class_name AmmoData

@export var ammo_types: Array[Ammo] = []

func get_ammo(query):
  if not get_node_or_null(query):
    var ats = get_children()
    for at in ats:
      if at.type_name == query or at.short_name == query or at.display_name == query:
        return at
  else:
    return get_node_or_null(query)
