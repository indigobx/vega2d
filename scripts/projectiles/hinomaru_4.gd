extends RigidBody2D

var ascend_angle: float = 30.0
var direction
# 0 - power ascend
# 1 - inertial ascend
# 2 - aim
# 3 - thrust to target
# 4 - inertial flight
var v1
var stage: int
var target_position: Vector2
var stage_timers_base = [
  0.45, 0.25, 0.5, 0.5, 4
]  # 0   1    2    3    4
var stage_timers: Array = []
var hit_scene = preload("res://scenes/fx/small_hit_explode.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  for t in stage_timers_base:
    stage_timers.append(randf_range(t*0.85, t*1.15))
  direction = sign(GM.angle_from_up_degrees(global_rotation_degrees))
  if GM.weapon.locked_target:
    target_position = GM.weapon.locked_target.global_position
  if target_position:
    v1 = Vector2(randf_range(4, 6), 0).rotated(global_rotation)
    $EngineTimer.start(stage_timers[0])
    stage = 0
  else:
    v1 = Vector2(randf_range(12, 17), 0).rotated(global_rotation)
    $LifeTimer.start(stage_timers[4])
    stage = 4
  apply_impulse(v1)
  $Sprite.play("fly")
  $Light.enabled = true
  $Light.kind = "sine"
  particles_fly()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
  if target_position:
    #$DebugLine1.points[1] = to_local(target_position)
    var up_angle = abs(GM.angle_from_up_degrees(global_rotation_degrees))
    match stage:
      0:
        if up_angle < ascend_angle:
          apply_torque_impulse(-3.5 * direction)
        elif up_angle > ascend_angle:
          apply_torque_impulse(3.5 * direction)
        apply_impulse(Vector2(randf_range(4, 6), 0).rotated(global_rotation))
        linear_velocity.limit_length(80)
      1:
        rotate_to_target(0.25)
      2:
        look_at(target_position)
        linear_velocity = lerp(linear_velocity, Vector2.ZERO, 0.05)
      3:
        look_at(target_position)
        apply_impulse(Vector2(randf_range(10, 20), 0).rotated(global_rotation))
        linear_velocity.limit_length(90)
      4:
        #angular_velocity = lerpf(angular_velocity, 0, 0.25)
        $Particles.emitting = false
        look_at(target_position)
      _:
        $Particles.emitting = false
        pass
  else:
    particles_fly()
    apply_impulse(Vector2(randf_range(8, 12), 0).rotated(global_rotation))
    linear_velocity.limit_length(90)


func rotate_to_target(power) -> void:
  # v1
  #var angle_to_target = position.angle_to_point(to_local(target_position))
  #if global_rotation - angle_to_target > 0.0:
    #apply_torque_impulse(power * direction)
  #elif global_rotation - angle_to_target < 0.0:
    #apply_torque_impulse(-power * direction)
  # v2
  #look_at(target_position)
  rotation = lerp(
    rotation,
    rotation + get_angle_to(target_position),
    power
  )

func particles_fly() -> void:
  $Particles.emitting = true
  $Particles.process_material.spread = 5
  $Particles.process_material.initial_velocity_min = 25
  $Particles.process_material.initial_velocity_max = 120

func particles_aim() -> void:
  $Particles.emitting = true
  $Particles.process_material.spread = 60
  $Particles.process_material.initial_velocity_min = 30
  $Particles.process_material.initial_velocity_max = 60

func hit_fx() -> void:
  var hit_instance = hit_scene.instantiate()
  hit_instance.global_position = global_position
  hit_instance.global_rotation = global_rotation
  GlobalFx.add_fx(hit_instance)

func _on_damage_area_entered(area: Area2D) -> void:
  if area and area.get_parent().has_method("take_damage"):
    var damage = ADB.get_ammo("hinomaru_4").damage_base * linear_velocity.length() * 0.001
    area.get_parent().take_damage(damage, area)
    hit_fx()
    queue_free()
    #hide_and_remove()



func _on_engine_timer_timeout() -> void:
  $InertialTimer.start(stage_timers[1])
  stage = 1
  $Sprite.play("aim")
  $Light.enabled = true
  $Light.kind = "flicker"
  particles_aim()


func _on_aim_timer_timeout() -> void:
  $InertialTimer.start(stage_timers[3])
  stage = 3
  particles_fly()
  $Light.enabled = true
  $Light.kind = "sine"
  $Sprite.play("fly")


func _on_life_timer_timeout() -> void:
  queue_free()


func _on_inertial_timer_timeout() -> void:
  if stage == 1:
    $AimTimer.start(stage_timers[2])
    $Sprite.play("aim")
    $Light.enabled = true
    $Light.kind = "flicker"
    particles_fly()
    stage = 2
  else:
    $LifeTimer.start(stage_timers[4])
    $Sprite.play("default")
    $Light.enabled = false
    $Particles.emitting = false
    stage = 4
    


func _on_body_entered(_body: Node) -> void:
  hit_fx()
  queue_free()
