extends Node
class_name WeaponsData

@export var weapons: Array[Weapon] = []

func get_weapon(query):
  if not get_node_or_null(query):
    var ws = get_children()
    for w in ws:
      if w.short_name == query or w.display_name == query:
        return w
  else:
    return get_node_or_null(query)
