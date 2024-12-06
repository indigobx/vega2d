extends CharacterBody2D

var speed : float = 200.0
var jump_velocity : float = -400.0
var gravity : float = 900.0

# Словарь, содержащий сопоставления действиям анимаций
var action_animations = {
  "FirePrimary": "fire",
  #"Inter": "dash",
  #"Shield": "shield"
}

func _ready() -> void:
  Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
  set_process_input(true)
  $AnimationPlayer.play("STAND")

func _process(delta: float) -> void:
  var cursor = $Cursor
  
  # Обновляем позицию курсора
  cursor.position = get_global_mouse_position()

  # Определяем, какое действие выполняется, и переключаем анимацию
  var action_triggered = false
  for action in action_animations.keys():
    if Input.is_action_pressed(action):
      cursor.play(action_animations[action])
      action_triggered = true
      break

  # Если нет активных действий, проигрываем анимацию по умолчанию
  if not action_triggered:
    cursor.play("default")

  # Ограничиваем угол поворота рук
  var target_position = get_global_mouse_position()
  var direction = (target_position - global_position).normalized()
  var angle_to_target = direction.angle()
  var min_angle = deg_to_rad(-45)  # Минимальный угол в радианах
  var max_angle = deg_to_rad(45)   # Максимальный угол в радианах

  # Ограничиваем угол между -45 и 45 градусов
  angle_to_target = clamp(angle_to_target, min_angle, max_angle)


func _physics_process(delta: float) -> void:
  var cursor = $Cursor
  # Обработка ввода и обновление анимации
  if Input.is_action_just_pressed("FirePrimary"):
    $Cursor.play("fire")
    $AnimationPlayer.play("CROUCH")
  if Input.is_action_just_released("FirePrimary"):
    $AnimationPlayer.play("STAND")

  # Гравитация
  if not is_on_floor():
    velocity.y += gravity * delta

  # Обработка движения персонажа
  velocity.x = 0

  if Input.is_action_pressed("Left"):
    velocity.x = -speed
  elif Input.is_action_pressed("Right"):
    velocity.x = speed

  # Прыжок
  if is_on_floor() and Input.is_action_just_pressed("Jump"):
    velocity.y = jump_velocity

  # Применение движения
  move_and_slide()
