extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  $Booster1.linear_velocity.x *= GM.player.vega.view_direction
  $Booster2.linear_velocity.x *= GM.player.vega.view_direction
  $Booster1.linear_velocity *= Vector2(randf_range(0.9, 1.1), randf_range(0.9, 1.1))
  $Booster2.linear_velocity *= Vector2(randf_range(0.9, 1.1), randf_range(0.9, 1.1))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass
