extends CharacterBody2D

signal take_damage_received

@export var max_hp: int = 40
var hp = max_hp
const SPEED = 60.0
const JUMP_VELOCITY = -40.0
var drive_timer = 2

func drive() -> void:
  var direction = sign(randi_range(-1, 1))
  if direction > 0:
    $BodySprite.play("move")
  elif direction < 0:
    $BodySprite.play_backwards("move")
  else:
    $BodySprite.play("default")
  velocity.x = randi_range(10, SPEED) * direction

func take_damage(amount: int) -> int:
  hp -= amount
  print(hp)
  velocity.x = 0
  $BodySprite.play("hit")
  if hp <= 0:
    die()
  return min(hp, 0)

func die():
  $BodySprite.sprite_frames.set_animation_loop("hit", true)
  $BodySprite.play("hit")
  velocity.x = 0
  $BodySprite.modulate = "#ccc"


func _ready() -> void:
  add_to_group("enemies")

func _physics_process(delta: float) -> void:
  drive_timer -= delta
  if drive_timer <= 0 and hp > 0:
    drive()
    drive_timer = 2
  

  if not is_on_floor():
    velocity += get_gravity() * delta
  move_and_slide()


func _on_body_sprite_animation_finished() -> void:
  $BodySprite.play("default")
