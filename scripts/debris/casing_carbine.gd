extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  linear_velocity.x = GM.player.vega.view_direction * randi_range(20, 40)
  linear_velocity.y = randi_range(-75, -150)
  await get_tree().create_timer(5).timeout
  sleeping = true
  freeze = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
  pass


func _on_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
  print("sfx")
  GM.audio.add_sfx(GM.audio.get_random_sound("casing_drop"), global_position)
