extends RigidBody2D

@export var max_hp = 100
var hp = max_hp
@export var thruster_power: float
@export var patrol_altitude: float
var current_altitude: float = 120.0
var altitude_array = []
var patrol_timer: float = 1.0
var direction: int = 1
var safe_altitude: float = 90.0
var swipe_increment: float = 1.0
var is_dead = false
var vega_found = false
@export var damage_text_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  $PatrolTimer.start(patrol_timer)
  thrust_side(direction, safe_altitude)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  $Altimeter.global_rotation = 0
  $SensorLeft.global_rotation = 0
  $SensorRight.global_rotation = 0
  $Healthbar.global_rotation = 0

func _physics_process(delta: float) -> void:
  if is_dead:
    return
  if $SensorLeft.is_colliding():
    direction = 1
  if $SensorRight.is_colliding():
    direction = -1
  if abs(rotation_degrees) > 30:
    $BodySprite.play("default")
    rotation = lerpf(rotation, 0.0, 0.5)
  else:
    if linear_velocity.y < -80:
      return
    else:
      keep_alt(patrol_altitude)
  if vega_found:
    keep_pos()
    if $TargetSeeker.is_colliding() and $TargetSeeker.get_collider().name != "Vega":
      vega_found = false
  else:
    var target = swipe_seeker()
    $Label.text = "%s" % target
    if target == "Vega":
      vega_found = true
    else:
      vega_found = false

#func swipe_seeker() -> Variant:
  #var swipe_increment = 1.0
  #if abs($TargetSeeker.rotation_degrees) >= 60:
    #swipe_increment = -swipe_increment
  #$TargetSeeker.rotation_degrees += swipe_increment
  #$Label.text = "%s" % target

func swipe_seeker() -> Variant:
  if abs($TargetSeeker.rotation_degrees) >= 60:
    swipe_increment = -swipe_increment
  $TargetSeeker.rotation_degrees = lerpf(
    $TargetSeeker.rotation_degrees,
    $TargetSeeker.rotation_degrees + swipe_increment,
    0.8
  )
  if $TargetSeeker.is_colliding():
    return $TargetSeeker.get_collider().name
  else:
    return null
  


func measure_alt() -> float:
  altitude_array.append(
    $Altimeter.get_collision_point().y - position.y
  )
  if altitude_array.size() > 1:
    altitude_array.pop_front()
  var total_altitude = 0.0
  for altitude in altitude_array:
    total_altitude += altitude
  return total_altitude / altitude_array.size()

func keep_pos() -> void:
  thrust_side(-linear_velocity.x*0.01, 40)


func keep_alt(alt) -> void:
  rotation = lerpf(rotation, 0.0, 0.3)
  if $Altimeter.is_colliding():
    current_altitude = measure_alt()
  if current_altitude < alt:
    var impulses = int((patrol_altitude - current_altitude)*0.1)
    for i in range(impulses):
      thrust_up()
    $BodySprite.play("default")
    $AudioStreamPlayer2D.playing = false

func thrust_up() -> void:
  $EngineTimer.start(0.01)


func thrust_side(direction, critical_alt) -> void:
  if $Altimeter.is_colliding():
    current_altitude = measure_alt()
  if current_altitude <= critical_alt:
    return
  else:
    if direction < 0:
      $BodySprite.play("fly-left")
    else:
      $BodySprite.play("fly-right")
    $AudioStreamPlayer2D.playing = true
    apply_impulse(Vector2(direction * thruster_power, 0).rotated(rotation))

func take_damage(amount: int) -> int:
  if is_dead:
    return 0
  else:
    var damage_text = damage_text_scene.instantiate()
    damage_text.text = "-%d" % amount
    damage_text.global_position = global_position + Vector2(0, -20)
    get_tree().current_scene.add_child(damage_text)
  hp -= amount
  print(hp)
  #velocity.x = 0
  if hp <= 0:
    die()
  return min(hp, 0)

func die() -> void:
  lock_rotation = false
  thruster_power = 0.0
  is_dead = true
  $AudioStreamPlayer2D.playing = false
  $BodySprite.play("dead")
 
  
func _on_patrol_timer_timeout() -> void:
  if !is_dead:
    thrust_side(direction, safe_altitude)
    $PatrolTimer.start()


func _on_engine_timer_timeout() -> void:
  if !is_dead:
    $BodySprite.play("fly-up")
    $AudioStreamPlayer2D.playing = true
    apply_impulse(Vector2(0, -thruster_power).rotated(rotation))
