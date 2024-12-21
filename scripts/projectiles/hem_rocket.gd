extends RigidBody2D

var explosion_scene = preload("res://scenes/explosions/hem_explosion_logic.tscn")
var shrapnel_scene = preload("res://scenes/debris/shrapnel.tscn")
var armed = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  apply_impulse(Vector2(100, 0).rotated(GM.player.vega.arms_pivot.global_rotation))
  $LaunchTimer.start()
  $SelfDestructTimer.start()
  $ExplosionSensor.monitoring = false
  $GPUParticles2D.emitting = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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


func _on_explosion_sensor_area_entered(area: Area2D) -> void:
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
