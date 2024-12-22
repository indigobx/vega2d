extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@export var is_dead:bool = false
@export var hp: float = 100.0
@export var max_hp: float = 100.0
var damage_text_scene = preload("res://scenes/ui/damage_text.tscn")


func _physics_process(delta: float) -> void:
  # Add the gravity.
  if not is_on_floor():
    velocity += get_gravity() * delta
  move_and_slide()


func take_damage(amount, zone) -> void:
  if is_dead:
    return
  else:
    var hp_factor = hp / max_hp
    if zone:
      match zone.name:
        "Head":
          amount *= 2.0
        _:
          amount = amount
    var damage_text = damage_text_scene.instantiate()
    damage_text.text = "-%d" % amount
    damage_text.global_position = $DamageTextOrigin.global_position
    get_tree().current_scene.add_child(damage_text)
    hp -= amount
    velocity.x = 0
    if hp_factor > 0.9:
      $Sprite.play("default")
    elif hp_factor > 0.7:
      $Sprite.play("dmg_1")
    elif hp_factor > 0.5:
      $Sprite.play("dmg_2")
    elif hp_factor > 0.3:
      $Sprite.play("dmg_3")
    elif hp_factor > 0.1:
      $Sprite.play("dmg_4")
    elif hp <= 0:
      call_deferred("die")

func die() -> void:
  hp = 0
  is_dead = true
  $Sprite.play("die")
  $Torso.monitorable = false
  $Head.monitorable = false
  await $Sprite.animation_finished
  process_mode = Node.PROCESS_MODE_DISABLED
