extends RigidBody2D

var fragments = [
  Rect2i(4, 3, 3, 5),
  Rect2i(22, 5, 3, 4),
  Rect2i(37, 4, 6, 7),
  Rect2i(55, 5, 3, 5)
]
@export var max_impulse: float = 500.0
@export_range(-180, 180, 1.0) var base_angle: float = 0.0
@export_range(0.0, 180.0, 1.0) var cone_angle: float = 45.0
@export var damage: float = 5.0

func rand_vector(vmax) -> Vector2:
  var rand_angle = randf_range(-cone_angle, cone_angle)
  var direction = Vector2.from_angle(deg_to_rad(base_angle)).rotated(deg_to_rad(rand_angle)).normalized()
  return direction * randf_range(0, vmax)

func disable() -> void:
  process_mode = Node.PROCESS_MODE_DISABLED

func _ready() -> void:
  randomize()
  var fragment = fragments.pick_random()
  $Fragment.texture = $Fragment.texture.duplicate()
  $Fragment.texture.region = fragment
  $Collision.shape.size = fragment.size
  $Damage/Collision2.shape.size = fragment.size
  linear_velocity = rand_vector(max_impulse/10)
  angular_velocity = randf_range(-max_impulse, max_impulse)
  apply_impulse(rand_vector(max_impulse))
  apply_torque_impulse(randf_range(-max_impulse, max_impulse))
  $Timer.start(2.5)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
  if $Timer.is_stopped() or abs(linear_velocity.length_squared()) < 1.0:
    disable()
    freeze = true


func _on_damage_area_entered(target: Area2D) -> void:
  if target and target.get_parent().has_method("take_damage"):
    damage = clamp(linear_velocity.length()/10, 0.5, 30.0)
    target.get_parent().take_damage(damage, target)
  call_deferred("disable")
  $Damage.queue_free()
