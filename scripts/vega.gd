extends CharacterBody2D

var footprint_scene = preload("res://scenes/decals/footprint.tscn")
var speed_mod: float = 1.0
var speed_mod_max: float = 20.0
var base_speed: float = 240.0
var base_speed_back: float = -60.0
var jump_velocity : float = -400.0
var gravity : float = 15.0
var direction: Vector2
var direction_angle_threshold_deg: float = 15.0
var cursor: Vector2
var arms_angle: float
var recoil_angle: float = 0.0
var mod_angle: float = 0.0
var _view_direction: int = 1
var view_direction: int:
  get:
    return _view_direction
  set(value):
    if value != _view_direction:
      _view_direction = value
      _on_view_direction_changed(value)
var action_forward: String = "Left"
var action_back: String = "Right"
var body_animation: String = "unarmed"
var arms_pivot: Node
var ray: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
  set_process_input(true)
  ray = $ArmsPivot/Arms/RayCast2D
  arms_pivot = $ArmsPivot
  _on_view_direction_changed(1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  cursor = get_local_mouse_position()
  GM.camera.offset = lerp(GM.camera.offset, cursor/3, 0.05)
  if GM.player.selected_weapon != 0:
    $ArmsPivot/Arms.visible = true
    body_animation = "armed"
  else:
    $ArmsPivot/Arms.visible = false
    body_animation = "unarmed"

func _physics_process(delta: float) -> void:
  
  $Line2D.points[1] = cursor
  $Cursor.position = cursor
  
  #direction = (to_global(cursor) - global_position).normalized()
  direction = global_position.direction_to(to_global(cursor)).normalized()
  var cursor_angle = rad_to_deg(abs(direction.angle()))
  if cursor_angle > 90 + direction_angle_threshold_deg:
    view_direction = -1
  elif cursor_angle < 90 - direction_angle_threshold_deg:
    view_direction = 1

  
  var angle_limit = deg_to_rad(45)
  mod_angle = lerp(mod_angle, recoil_angle, 0.25)
  arms_angle = abs(direction.rotated(deg_to_rad(90)).angle()) - deg_to_rad(90)
  arms_angle = clamp(arms_angle+mod_angle, -angle_limit, angle_limit) * view_direction
  if sign(view_direction) == sign(direction.x):  # This should not lower arms when cursor is behind
    $ArmsPivot.rotation = lerpf($ArmsPivot.rotation, arms_angle, 0.2)  # Replace weight with weapon weight here!
  
  if Input.is_action_pressed(action_forward):
    velocity.x = lerpf(velocity.x, (speed_mod + base_speed) * view_direction, 0.3)
    #$Character/Body.play("walk-forward-3-unarmed")
  
  if Input.is_action_pressed(action_back):
    velocity.x = lerpf(velocity.x, (speed_mod + base_speed_back) * view_direction, 0.3)
    #$Character/Body.play("walk-back-3-unarmed")
  
  if is_on_floor() and Input.is_action_just_pressed("Jump"):
    velocity.y = jump_velocity
  
  if not is_on_floor():
    velocity.y += gravity
    #$Character/Body.play("jump-3-unarmed")
  
  if not Input.is_anything_pressed():
    velocity.x = lerpf(velocity.x, 0.0, 0.5)
  
  
  if Input.is_action_pressed("Fire"):
    if GM.player.selected_weapon != 0:
      if not GM.weapon.single_fire_lock:
        GM.weapon.fire()
  if Input.is_action_just_released("Fire"):
    GM.weapon.single_fire_lock = false
  if GM.weapon.weapon and GM.weapon.weapon.mag == 0 and GM.player.ammo[GM.weapon.weapon.ammo_type] > 0:
    $Label.text = "I have to reload!"
  else:
    $Label.text = "%s" % rad_to_deg(recoil_angle)
  
  if Input.is_action_just_pressed("FireMode"):
    GM.weapon.toggle_fire_mode()
  
  if Input.is_action_just_pressed("Reload"):
    GM.weapon.reload()
  
  if Input.is_action_just_pressed("Unjam"):
    GM.weapon.unjam()
  
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
    $Character/Body.play("walk-forward-3-%s" % body_animation)
  if is_on_floor() and velocity.x * view_direction < 0.1 * -view_direction:
    $Character/Body.play("walk-back-3-%s" % body_animation)
  if is_on_floor() and abs(velocity) <= Vector2(0.1, 0.1):
    $Character/Body.play("wait1-3-%s" % body_animation)
  if not is_on_floor() and abs(velocity.y) > 0.1:
    $Character/Body.play("jump-3-%s" % body_animation)

  move_and_slide()



func sine_move(frame: int, total_frames: int, max_vector: Vector2) -> Vector2:
  frame = frame % total_frames
  var angle = float(frame) / float(total_frames) * PI
  var scale = sin(angle)
  return Vector2(scale * max_vector.x, scale * max_vector.y)


func _on_view_direction_changed(vd) -> void:
  if vd == -1:
    $Character/Body.flip_h = true
    $Collision.scale.x = -1
    $Collision.position.x = -9
    $ArmsPivot.scale.x = -1
    #$ArmsPivot/Arms/RayCast2D.position.x = -30
    #$ArmsPivot.position.x = -4
    $ShadowSprite.position.x = -4
    action_back = "Right"
    action_forward = "Left"
  else:
    $Character/Body.flip_h = false
    $Collision.scale.x = 1
    $Collision.position.x = 9
    $ArmsPivot.scale.x = 1
    #$ArmsPivot/Arms/RayCast2D.position.x = 30
    #$ArmsPivot.position.x = 4
    $ShadowSprite.position.x = 4
    action_back = "Left"
    action_forward = "Right"


func _on_body_frame_changed() -> void:
  var max_frames = $Character/Body.sprite_frames.get_frame_count($Character/Body.animation)
  speed_mod = speed_mod_max * sin((float($Character/Body.frame) / float(max_frames)) * 2*PI)
  # footprints
  if $Character/Body.frame in [3, 7] \
  and abs(velocity.x) > 1.0 \
  and is_on_floor():
    var footprint = footprint_scene.instantiate()
    footprint.global_position = global_position + Vector2(13*view_direction, 52)
    GlobalFx.add_decal(footprint)
  
  # arms pivot movement
  if $Character/Body.animation.ends_with("-armed") and \
    $Character/Body.animation.begins_with("walk"):
    $ArmsPivot.position = Vector2(4*view_direction, -14) +\
      sine_move($Character/Body.frame, 10, Vector2(4*view_direction, 4))
    $ArmsPivot.rotation_degrees = lerpf(
      $ArmsPivot.rotation_degrees,
      $ArmsPivot.rotation_degrees + randf_range(0.0, 15.0),
      0.2
    )
  else:
    $ArmsPivot.position = Vector2(4*view_direction, -14)
