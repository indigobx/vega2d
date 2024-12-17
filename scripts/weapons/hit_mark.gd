extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  scale = Vector2(randf_range(0.75, 1.5), randf_range(0.75, 1.5))
  rotation_degrees = randf_range(0, 360)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass
