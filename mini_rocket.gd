extends RigidBody2D

@export var force = 1000.0
@export var acceleration_time = 0.625
@export var fuse_distance = 240
@export var defuse_timer = 2.0
@export var damage = 25
var total_distance = 0.0
var previous_position = Vector2()
var fuse_on = false
var engine_on = true
@export var direction = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  if sign(direction.x) < 0:
    $MiniRocketSprite.flip_h = true
    $MiniRocketSprite.offset = Vector2(24, 0)
    force = -force
  if not is_connected("body_entered",_on_body_entered):
    connect("body_entered", _on_body_entered)
  previous_position = global_position
  rotation = rotation + deg_to_rad(randf_range(-2, 2))
  apply_impulse(Vector2(force/3, 0).rotated(rotation))
  await get_tree().create_timer(defuse_timer).timeout
  self_destruct()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass


func _physics_process(delta: float) -> void:
  var active_time_left = acceleration_time
  var dyn_force = force * (active_time_left / 1.0) * randf_range(0.9, 1.1)
  var frame_distance = previous_position.distance_to(global_position)
  angular_velocity += randf_range(-0.5, 0.5)
  if total_distance < fuse_distance and engine_on:
    total_distance += frame_distance
    previous_position = global_position
  if total_distance >= fuse_distance and engine_on:
    fuse_on = true
  if active_time_left >= 0 and engine_on:
    apply_force(Vector2(dyn_force, 0).rotated(rotation))
    active_time_left -= delta
  if active_time_left <=0:
    $PointLight2D.enabled = false


func self_destruct():
  $PointLight2D.enabled = false
  $MiniRocketSprite.frame = 10
  sleeping = true
  engine_on = false
  $EngineSound.playing = false
  fuse_on = false
  set_collision_layer_value(1, false)
  set_collision_layer_value(2, false)
  await get_tree().create_timer(defuse_timer).timeout
  self_destruct()
  $MiniRocketSprite.visible = false
  $ExplosionSprite.visible = true
  $ExplosionSprite.play("defuse")


func explode():
  $PointLight2D.energy = 0.5
  $PointLight2D.scale = Vector2(4, 4)
  $PointLight2D.light_once("sine", 0.2, "off")
  $MiniRocketSprite.visible = false
  $ExplosionSprite.visible = true
  $ExplosionSprite.play("explode")
  $ExplosionSound.playing = true
  $Particles.emitting = true
  


func _on_body_entered(body: Node) -> void:
  if fuse_on:
    engine_on = false
    linear_velocity = Vector2.ZERO
    angular_velocity = 0.0
    $EngineSound.playing = false
    explode()
    if body.has_method("take_damage"):  # Проверяем наличие метода take_damage
      body.take_damage(damage)
  if !fuse_on:
    engine_on = false
    $EngineSound.playing = false
    linear_velocity = Vector2.ZERO
    self_destruct()


func _on_explosion_sprite_animation_finished() -> void:
  queue_free()
