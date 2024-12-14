extends CharacterBody2D

signal take_damage_received

@export var max_hp: int = 60
var hp = max_hp
var speed = 120.0
const JUMP_VELOCITY = -40.0
var drive_timer = 2
var is_dead = false
var direction = Vector2(1, 0)
var seek_side = "right"
var seek_speed = 0.4
var seek_UR = -15
var seek_DR = 15
var seek_UL = -165
var seek_DL = -195
var state = "seek"
var target
var attack_delay = 1.0
var attack_timer = 0.0
@export var damage_text_scene: PackedScene
@export var weapon_damage = 5
var bullet_scene = preload("res://bullet.tscn")

func drive(drive_direction) -> void:
  if drive_direction > 0:
    $BodySprite.play("move")
    $WheelsSprite.play("move")
  elif drive_direction < 0:
    $BodySprite.play("move")
    $WheelsSprite.play_backwards("move")
  else:
    $BodySprite.play("default")
    $WheelsSprite.play("default")
  velocity.x = speed * drive_direction

func take_damage(amount: int) -> int:
  if is_dead:
    return 0
  else:
    var damage_text = damage_text_scene.instantiate()
    damage_text.text = "-%d" % amount
    damage_text.global_position = global_position + Vector2(0, -20)
    get_tree().current_scene.add_child(damage_text)
  hp -= amount
  velocity.x = 0
  $BodySprite.play("hit")
  $WheelsSprite.play("default")
  if hp <= 0:
    is_dead = true
    die()
  return min(hp, 0)

func die():
  $BodySprite.play("die")
  $WheelsSprite.play("die")
  $PointLight2D.enabled = true
  $CPUParticles2D.explosiveness = 0.15
  $CPUParticles2D.initial_velocity_min = 150.0
  $CPUParticles2D.initial_velocity_max = 350.0
  $CPUParticles2D.spread = 45
  velocity.x = 0
  $BodySprite.modulate = "#ccc"
  $WheelsSprite.modulate = "#ccc"
  $CPUParticles2D.emitting = true
  await get_tree().create_timer(1.0).timeout
  $PointLight2D.enabled = false
  await get_tree().create_timer(2.0).timeout
  $CPUParticles2D.explosiveness = 0.0
  $CPUParticles2D.initial_velocity_min = 30.0
  $CPUParticles2D.initial_velocity_max = 120.0
  $CPUParticles2D.spread = 20

func attack(times=5, delay=0.5):
  fire_mg(times)
  if delay > 0:
    $Timer.start(delay)
    await $Timer.timeout
  $Gun/Barrel/Flash.visible = false


func fire_mg(times=5):
  $Gun/Barrel/FlashLight.light_once("flicker", 0.1*times)
  $Gun/Barrel/Flash.visible = true
  for i in range(times):
    var bullet_instance = bullet_scene.instantiate()
    bullet_instance.direction = direction
    bullet_instance.animation_name = "tracer"
    bullet_instance.global_position = $Gun/Barrel/Flash.global_position
    bullet_instance.rotation = $Gun.rotation
    bullet_instance.damage = weapon_damage
    bullet_instance.spread = 200
    GlobalFx.add_fx(bullet_instance)
    $Timer.start(0.1)
    await $Timer.timeout
  $Gun/Barrel/Flash.visible = false
  

func _ready() -> void:
  $Hull.set_meta("armor", "aluminium")
  $Tower.set_meta("armor", "rha")
  $WheelFront.set_meta("armor", "rubber")
  $WheelRear.set_meta("armor", "rubber")


func _physics_process(delta: float) -> void:
  drive_timer -= delta
  if drive_timer <= 0 and hp > 0:
    if state == "seek":
      speed = 120
      drive(randi_range(-1, 1))
      drive_timer = 2
  if not is_on_floor():
    velocity += get_gravity() * delta
  
  if state == "seek" and !is_dead:
    if seek_side == "right":
      $Ray.rotation = lerpf($Ray.rotation, deg_to_rad(seek_DR), seek_speed)
    if seek_side == "left":
      $Ray.rotation = lerpf($Ray.rotation, deg_to_rad(seek_DL), seek_speed)
    if abs($Ray.rotation_degrees - seek_DR) <= 0.01:
      seek_side = "left"
      $Ray.rotation_degrees = seek_UL
    if abs($Ray.rotation_degrees - seek_DL) <= 0.01:
      seek_side = "right"
      $Ray.rotation_degrees = seek_UR
  
  if $Ray.is_colliding() and $Ray.get_collider().name == "Vega" and !is_dead:
    target = $Ray.get_collider()
    state = "aim"
    $Gun/LaserTarget.enabled = true
    $Ray/LaserSeek.enabled = false
    $Gun.rotation = lerpf($Gun.rotation, get_angle_to(target.global_position), 0.05)
    $Gun.position = lerp($Gun.position, Vector2(0, -10), 0.05)
    if $Gun.rotation_degrees < seek_UL:
      $Gun.rotation_degrees = clamp($Gun.rotation_degrees, seek_DL, seek_UL)
    if $Gun.rotation_degrees > seek_UR:
      $Gun.rotation_degrees = clamp($Gun.rotation_degrees, seek_UR, seek_DR)
    if attack_timer >= attack_delay:
      attack(5, 0.1)
      attack_timer = 0.0
    attack_timer += delta
  else:
    state = "seek"
    $Gun/LaserTarget.enabled = false
    $Ray/LaserSeek.enabled = true
    $Gun.rotation_degrees = lerpf($Gun.rotation_degrees, -90, 0.05)
    $Gun.position = lerp($Gun.position, Vector2(0, 14), 0.05)
  
  move_and_slide()

#func _on_body_sprite_animation_finished() -> void:
  #$BodySprite.play("default")
