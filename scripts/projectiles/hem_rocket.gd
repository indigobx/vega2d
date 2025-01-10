extends RigidBody2D

var explosion_scene = preload("res://scenes/explosions/hem_explosion_logic.tscn")
var shrapnel_scene = preload("res://scenes/debris/shrapnel.tscn")
var armed: bool = false
var critical_speed_2: float = 1.0 ** 2
var critical_lon_g_2: float = 2000.0 ** 2
var critical_ang_g: float = 250.0
var previous_velocity: Vector2
var previous_angular_velocity: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  apply_impulse(Vector2(100, 0).rotated(GM.player.vega.arms_pivot.global_rotation))
  $LaunchTimer.start()
  $SelfDestructTimer.start()
  $ExplosionSensor.monitoring = false
  $GPUParticles2D.emitting = false
  previous_velocity = linear_velocity
  previous_angular_velocity = angular_velocity


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
  if $LaunchTimer.is_stopped() and not armed:
    armed = true
    $EngineTimer.start()
    $ArmTimer.start()
  if not $EngineTimer.is_stopped():
    $GPUParticles2D.emitting = true
    apply_impulse(Vector2(200, 0).rotated(global_rotation))
  else:
    $GPUParticles2D.emitting = false
  if $ArmTimer.is_stopped() and armed:
    $ExplosionSensor.monitoring = true
  if $SelfDestructTimer.is_stopped():
    call_deferred("explode")
  
  #if $ArmTimer.is_stopped() and armed:
    #var velocity_delta_2 = (linear_velocity - previous_velocity).length_squared() 
    #var angular_acceleration = abs(angular_velocity - previous_angular_velocity) / delta
    #if velocity_delta_2 > critical_lon_g_2:
      #call_deferred("explode")
    #if angular_acceleration > critical_ang_g:
      #call_deferred("explode")

func _on_explosion_sensor_area_entered(_area: Area2D) -> void:
  call_deferred("explode")


func explode() -> void:
  var explosion = explosion_scene.instantiate()
  explosion.global_position = global_position
  GM.level.add_child(explosion)
  var shrapnel_count = 20
  var shrapnel_cone = 45
  var shrapnel_angle = 45
  for i in range(shrapnel_count):
    var shrapnel = shrapnel_scene.instantiate().duplicate()
    shrapnel.base_angle = global_rotation_degrees + shrapnel_angle
    shrapnel.cone_angle = shrapnel_cone
    shrapnel.global_position = global_position
    GlobalFx.add_debris(shrapnel)
  for i in range(shrapnel_count):
    var shrapnel = shrapnel_scene.instantiate().duplicate()
    shrapnel.base_angle = global_rotation_degrees - shrapnel_angle
    shrapnel.cone_angle = shrapnel_cone
    shrapnel.global_position = global_position
    GlobalFx.add_debris(shrapnel)
  queue_free()
