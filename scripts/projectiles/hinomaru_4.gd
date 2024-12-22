extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  var v1 = Vector2(25, 0).rotated(GM.player.vega.arms_pivot.global_rotation)
  apply_impulse(v1)
  $Timer.start(0.5)
  $Sprite.play("fly")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  if not $Timer.is_stopped():
    apply_impulse(Vector2(5, 0).rotated(global_rotation))
    linear_velocity.limit_length(200)


func _on_timer_timeout() -> void:
  $Sprite.play("default")


func _on_damage_area_entered(area: Area2D) -> void:
  if area and area.get_parent().has_method("take_damage"):
    var damage = ADB.get_ammo("hinomaru_4").damage_base * linear_velocity.length() * 0.001
    area.get_parent().take_damage(damage, area)
    queue_free()
