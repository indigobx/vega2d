extends VBoxContainer

var mode: String
  
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass


func update() -> void:
  if GM.weapon.weapon:
    var modes = GM.weapon.weapon.get_fire_modes()
    for c in get_children():
      if c.name.to_lower() in modes:
        if c.name.to_lower() == mode:
          c.modulate = "white"
        else:
          c.modulate = Color("#ffd4a3", 0.75)
      else:
        c.modulate = Color("#ffd4a3", 0.25)
  else:
    for c in get_children():
      c.modulate = Color("gray", 0.1)
