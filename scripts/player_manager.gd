extends Node

var vega: Node = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass


func load_instance() -> void:
  vega = load("res://scenes/vega.tscn").instantiate()

func spawn(Vector2=Vector2.ZERO) -> void:
  add_child(vega)
  vega.global_position = Vector2
  var camera = load("res://scenes/player_camera.tscn").instantiate()
  vega.add_child(camera)
