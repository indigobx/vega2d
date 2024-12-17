extends Line2D

@export var hit_point: Vector2

func _ready() -> void:
  texture = texture.duplicate(true)

func _process(delta: float) -> void:
  if texture.gradient.get_offset(1) < 1:
    texture.gradient.set_offset(1, texture.gradient.get_offset(1) + 0.1)
    width += 2
  else:
    $AnimatedSprite2D.visible = true
    $AnimatedSprite2D.global_position = hit_point
    $AnimatedSprite2D.play("default")


func _on_animated_sprite_2d_animation_finished() -> void:
  queue_free()
