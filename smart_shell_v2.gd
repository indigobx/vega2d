extends RigidBody2D

@export var direction: Vector2 = Vector2()
@export var start_impulse: float
@export var engine_impulse: float
@export var target_global: Vector2 = Vector2()
@export var target_locked: bool = false
@export var damage: float = 10.0
var angle_to_target
var target_hit: bool = false
var timer: float = 0.0
@export var accel_timer: float = 0.5
@export var aim_timer: float = 1.0
@export var self_destruct_timer: float = 2.5


func _ready() -> void:
  start_impulse *= randf_range(0.9, 1.1)
  engine_impulse *= randf_range(0.95, 1.05)
  accel_timer *= randf_range(0.8, 1.2)
  aim_timer *= randf_range(0.7, 1.1)
  self_destruct_timer *= randf_range(0.8, 1.0)
  if sign(direction.x) < 0:
    rotation = deg_to_rad(180) + rotation
  apply_impulse(Vector2(start_impulse, 0).rotated(rotation))


func _physics_process(delta: float) -> void:
  timer += delta
  $SmartSprite.play("fly")
  if timer <= accel_timer and !target_locked:
    apply_impulse(Vector2(engine_impulse*1.5, 0).rotated(rotation))
  if !target_hit and timer <= accel_timer and target_locked:
    var aim_up_torque = -(rotation_degrees + 90)
    aim_up_torque *= 0.1
    apply_torque(aim_up_torque)
    if rotation_degrees > -100 and rotation_degrees < -80:
      apply_impulse(Vector2(engine_impulse*1.5, 0).rotated(rotation))
      $Particles.process_material.initial_velocity_min = 95
      $Particles.process_material.initial_velocity_max = 135
    else:
      apply_impulse(Vector2(engine_impulse/3, 0).rotated(rotation))
      $Particles.process_material.initial_velocity_min = 70
      $Particles.process_material.initial_velocity_max = 90
    $Particles.process_material.spread = 5
  if !target_locked and timer > accel_timer:
    $SmartSprite.play("default")
    $Particles.emitting = false
  if target_locked and !target_hit and timer > accel_timer and timer <= aim_timer:
    if $SmartSprite.animation != "aim":
      $SmartSprite.play("aim")
      $EngineSound.playing = true
    # add seek and fly logic
    $Particles.process_material.spread = 30
    $Particles.process_material.initial_velocity_min = 95
    $Particles.process_material.initial_velocity_max = 135
    var target_angle = global_position.angle_to_point(target_global)
    rotation = lerp(rotation, target_angle, 0.05)
    #rotation = target_angle + PI
    linear_velocity = lerp(linear_velocity, Vector2.ZERO, 0.1)
  if target_locked and !target_hit and timer > aim_timer:
    #angular_velocity = lerp(angular_velocity, 0.0, 0.1)
    apply_impulse(Vector2(engine_impulse*1.5, 0).rotated(rotation))
    rotation = global_position.angle_to_point(target_global)
    $SmartSprite.play("default")
  if timer >= self_destruct_timer:
    explode()

func explode():
  $SmartSprite.visible = false
  $ExplosionSprite.visible = true
  $ExplosionSprite.play("defuse")

func _on_body_entered(body: Node) -> void:
  linear_velocity = Vector2.ZERO
  angular_velocity = 0.0
  explode()
  if body.has_method("take_damage") and !target_hit:
    body.take_damage(damage)
    target_hit = true


func _on_explosion_sprite_animation_finished() -> void:
  queue_free()
