extends CharacterBody2D

var speed : float = 240.0
var base_speed: float = 240.0
var jump_velocity : float = -400.0
var gravity : float = 981.0
var direction: Vector2
var view_direction: float
var direction_angle_threshold_deg: float = 15.0
var cursor: Vector2
var arms_angle: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
  set_process_input(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass


func _physics_process(delta: float) -> void:
  cursor = get_local_mouse_position()
  $Line2D.points[1] = cursor
  $Cursor.position = cursor
  
  direction = (to_global(cursor) - global_position).normalized()
  var cursor_angle = rad_to_deg(abs(direction.angle()))
  if cursor_angle > 90 + direction_angle_threshold_deg:
    view_direction = -1
  elif cursor_angle < 90 - direction_angle_threshold_deg:
    view_direction = 1
  
  arms_angle = clamp(direction.angle(), -PI/4, PI/4) * view_direction
  if sign(view_direction) == sign(direction.x):  # This should not lower arms when cursor is behind
    $Line2D2.rotation = lerpf($Line2D2.rotation, arms_angle, 0.2)  # Replace weight with weapon weight here!
  
  if Input.is_action_just_pressed("Left"):
    speed = base_speed * -0.5
    velocity.x = lerpf(velocity.x, speed, 0.5)
    $Character/Body.play("walk-back-4-unarmed")
  if Input.is_action_just_pressed("Right"):
    speed = base_speed
    velocity.x = lerpf(velocity.x, speed, 1.0)
    $Character/Body.play("walk-forward-3-unarmed")
  
  if not is_on_floor():
    velocity.y += gravity
  
  if not Input.is_anything_pressed():
    velocity.x = lerpf(velocity.x, 0.0, 0.5)
  
  if abs(velocity) <= Vector2(0.1, 0.1):
    $Character/Body.play("wait1-4-unarmed")
  
  move_and_slide()
