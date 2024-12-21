extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  linear_velocity.x = GM.player.vega.view_direction * randi_range(20, 40)
  linear_velocity.y = randi_range(-75, -150)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass
