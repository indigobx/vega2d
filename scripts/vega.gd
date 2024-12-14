extends CharacterBody2D

var footprint_scene = preload("res://scenes/decals/footprint.tscn")
var speed : float = 240.0
var base_speed: float = 240.0
var base_speed_back: float = -60.0
var jump_velocity : float = -400.0
var gravity : float = 15.0
var direction: Vector2
var direction_angle_threshold_deg: float = 15.0
var cursor: Vector2
var arms_angle: float
var view_direction: int = 1
var action_forward: String = "Left"
var action_back: String = "Right"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
  set_process_input(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  cursor = get_local_mouse_position()
  GameManager.camera.offset = lerp(GameManager.camera.offset, cursor/3, 0.05)

func _physics_process(delta: float) -> void:
  
  $Line2D.points[1] = cursor
  $Cursor.position = cursor
  
  direction = (to_global(cursor) - global_position).normalized()
  var cursor_angle = rad_to_deg(abs(direction.angle()))
  if cursor_angle > 90 + direction_angle_threshold_deg:
    view_direction = -1
  elif cursor_angle < 90 - direction_angle_threshold_deg:
    view_direction = 1
  
  if view_direction == -1:
    flip()
  else:
    unflip()
  
  var angle_limit = deg_to_rad(45)
  arms_angle = abs(direction.rotated(deg_to_rad(90)).angle()) - deg_to_rad(90)
  arms_angle = clamp(arms_angle, -angle_limit, angle_limit) * view_direction
  if sign(view_direction) == sign(direction.x):  # This should not lower arms when cursor is behind
    $ArmsPivot.rotation = lerpf($ArmsPivot.rotation, arms_angle, 0.2)  # Replace weight with weapon weight here!
  
  if Input.is_action_pressed(action_forward):
    velocity.x = lerpf(velocity.x, base_speed * view_direction, 0.3)
    #$Character/Body.play("walk-forward-3-unarmed")
  
  if Input.is_action_pressed(action_back):
    velocity.x = lerpf(velocity.x, base_speed_back * view_direction, 0.3)
    #$Character/Body.play("walk-back-3-unarmed")
  
  if is_on_floor() and Input.is_action_just_pressed("Jump"):
    velocity.y = jump_velocity
  
  if not is_on_floor():
    velocity.y += gravity
    #$Character/Body.play("jump-3-unarmed")
  
  if not Input.is_anything_pressed():
    velocity.x = lerpf(velocity.x, 0.0, 0.5)
  
  $Label.text = "%.2d %.2d" % [velocity.x, velocity.y]
  
  # Fake Shadow
  if $ShadowRay.is_colliding():
    var shadow_distance = ($ShadowRay.get_collision_point() - global_position).y
    var shadow_factor = clamp((200 - (shadow_distance - 52)) / 200, 0.0, 1.0)
    $ShadowRay.force_raycast_update()
    $ShadowSprite.global_position = $ShadowRay.get_collision_point()
    $ShadowSprite.scale = Vector2(shadow_factor, shadow_factor)
    $ShadowSprite.modulate = Color(0, 0, 0, clamp(shadow_factor-0.5, 0.0, 1.0))

  # AnimationManager
  if is_on_floor() and velocity.x * view_direction > 0.1 * view_direction:
    $Character/Body.play("walk-forward-3-unarmed")
  if is_on_floor() and velocity.x * view_direction < 0.1 * -view_direction:
    $Character/Body.play("walk-back-3-unarmed")
  if is_on_floor() and abs(velocity) <= Vector2(0.1, 0.1):
    $Character/Body.play("wait1-3-unarmed")
  if not is_on_floor() and abs(velocity.y) > 0.1:
    $Character/Body.play("jump-3-unarmed")

  move_and_slide()


func flip() -> void:
  $Character/Body.flip_h = true
  $Collision.scale.x = -1
  $Collision.position.x = -9
  $ArmsPivot.scale.x = -1
  $ArmsPivot.position.x = -4
  $ShadowSprite.position.x = -4
  action_back = "Right"
  action_forward = "Left"

func unflip() -> void:
  $Character/Body.flip_h = false
  $Collision.scale.x = 1
  $Collision.position.x = 9
  $ArmsPivot.scale.x = 1
  $ArmsPivot.position.x = 4
  $ShadowSprite.position.x = 4
  action_back = "Left"
  action_forward = "Right"


func _on_body_frame_changed() -> void:
  if $Character/Body.frame in [3, 7] \
  and abs(velocity.x) > 1.0 \
  and is_on_floor():
    var footprint = footprint_scene.instantiate()
    footprint.global_position = global_position + Vector2(13*view_direction, 52)
    GlobalFx.add_decal(footprint)
