extends CharacterBody2D

signal take_damage_received

@export var max_hp: int = 60
var hp = max_hp
const SPEED = 120.0
const JUMP_VELOCITY = -40.0
var drive_timer = 2
var is_dead = false
@export var damage_text_scene: PackedScene

func drive() -> void:
  var direction = sign(randi_range(-1, 1))
  if direction > 0:
    $BodySprite.play("move")
    $WheelsSprite.play("move")
  elif direction < 0:
    $BodySprite.play("move")
    $WheelsSprite.play_backwards("move")
  else:
    $BodySprite.play("default")
    $WheelsSprite.play("default")
  velocity.x = randi_range(50, SPEED) * direction

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

func _ready() -> void:
  $Hull.set_meta("armor", "aluminium")
  $Tower.set_meta("armor", "rha")
  $WheelFront.set_meta("armor", "rubber")
  $WheelRear.set_meta("armor", "rubber")


func _physics_process(delta: float) -> void:
  drive_timer -= delta
  if drive_timer <= 0 and hp > 0:
    drive()
    drive_timer = 2
  

  if not is_on_floor():
    velocity += get_gravity() * delta
  move_and_slide()


#func _on_body_sprite_animation_finished() -> void:
  #$BodySprite.play("default")
