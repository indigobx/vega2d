extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  var random_angle = deg_to_rad(randf_range(-10.0, 10.0))
  var random_scale = randf_range(0.75, 1.25)
  self.rotation += random_angle
  self.scale = Vector2(random_scale, random_scale)
  


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass


func _on_sprite_animation_finished() -> void:
  queue_free()
