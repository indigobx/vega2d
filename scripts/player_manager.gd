extends Node

var vega: Node = null
var slots: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  for i in range(1, 9):
    slots[i] = null


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass


func load_instance() -> void:
  vega = load("res://scenes/vega.tscn").instantiate()

func spawn(Vector2=Vector2.ZERO) -> void:
  add_child(vega)
  vega.global_position = Vector2
  var camera = load("res://scenes/player_camera.tscn").instantiate()
  GM.camera = camera.get_node("Camera")
  vega.add_child(camera)


func put_to_slot(item, slot):
  slots[slot] = item

func clear_slots() -> void:
  for i in range(1, 9):
    slots[i] = null
