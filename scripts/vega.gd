extends CharacterBody2D

var footprint_scene = preload("res://scenes/decals/footprint.tscn")
var env_speed_mod: float = 1.0
var walk_speed_mod: float = 1.0
var walk_speed_mod_max: float = 20.0
var base_speed: float = 240.0
var base_speed_back: float = -60.0
var jump_velocity : float = -400.0
var charged_jump_power: float = 2.0
var gravity : float = 15.0
var direction: Vector2
var direction_angle_threshold_deg: float = 15.0
var cursor: Vector2
var camera_shake: Vector2
var arms_angle: float
var recoil_angle: float = 0.0
var mod_angle: float = 0.0
var recoil_position: Vector2 = Vector2.ZERO
var pregnancy_weight_mod: Dictionary = {
  0: 0.0,
  1: 2.0,
  2: 5.0,
  3: 10.0,
  4: 20.0,
  5: 35.0
}
var _pregnancy_stage: int = 0
var pregnancy_stage: int:
  get:
    return _pregnancy_stage
  set(value):
    _pregnancy_stage = value
    _on_pregnancy_stage_changed(value)
var weight_base: float = 65.0
var weight_total: float
var weapon_weight_mod: float = 0.7
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
var _weapon_offset: Vector2 = Vector2.ZERO
var weapon_offset: Vector2:
  get:
    return _weapon_offset
  set(value):
    _weapon_offset = value
    _on_weapon_offset_changed(value)
var ray: Node
var jump_charged: bool
var charged_jump_energy: float
var lock_area: Node
var init_weight: bool = false
var muzzle_flash_origin: Node
var heat_particles: Node
var shot_player: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
  set_process_input(true)
  ray = $ArmsPivot/Arms/RayCast2D
  arms_pivot = $ArmsPivot
  muzzle_flash_origin = $ArmsPivot/Arms/Weapon/MuzzleFlashOrigin
  heat_particles = $ArmsPivot/Arms/Weapon/HeatParticles
  shot_player = $ArmsPivot/Arms/Weapon/WeaponAudio
  GM.audio.shot_player = shot_player
  lock_area = get_node("Cursor/LockArea")
  _on_view_direction_changed(1)
  pregnancy_stage = 0



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
  if not init_weight:
    GM.inventory.open()
    GM.inventory.close()
    weight_total = GM.player.weight()
    init_weight = true
  cursor = get_local_mouse_position()
  GM.camera.offset = lerp(GM.camera.offset, cursor/3 + camera_shake, 0.05)
  if GM.ui.selected_slot != 0:
    $ArmsPivot/Arms.visible = true
    body_animation = "armed"
  else:
    $ArmsPivot/Arms.visible = false
    body_animation = "unarmed"


func _physics_process(_delta: float) -> void:
  
  $Line2D.points[1] = cursor
  $Cursor.position = cursor
  
  #direction = (to_global(cursor) - global_position).normalized()
  direction = global_position.direction_to(to_global(cursor)).normalized()
  var cursor_angle = rad_to_deg(abs(direction.angle()))
  if cursor_angle > 90 + direction_angle_threshold_deg:
    view_direction = -1
  elif cursor_angle < 90 - direction_angle_threshold_deg:
    view_direction = 1

  weapon_weight_mod = heavy_weapon()
  var angle_limit = deg_to_rad(45)
  mod_angle = lerpf(mod_angle, recoil_angle, 0.25)
  arms_angle = abs(direction.rotated(deg_to_rad(90)).angle()) - deg_to_rad(90)
  arms_angle = clamp(arms_angle+mod_angle, -angle_limit, angle_limit) * view_direction
  if sign(view_direction) == sign(direction.x):  # This should not lower arms when cursor is behind
    $ArmsPivot.rotation = lerpf($ArmsPivot.rotation, arms_angle, weapon_weight_mod)  # Replace weight with weapon weight here!

  var adjusted_speed = adjust_speed(base_speed)
  var adjusted_speed_back = adjust_speed(base_speed_back)
  var x_speed = (walk_speed_mod + adjusted_speed) * env_speed_mod
  if Input.is_action_pressed(action_forward):
    velocity.x = lerpf(velocity.x, x_speed * view_direction, weapon_weight_mod)
    #$Character/Body.play("walk-forward-3-unarmed")
  elif Input.is_action_pressed(action_back):
    velocity.x = lerpf(velocity.x, -x_speed * view_direction, weapon_weight_mod)
    #$Character/Body.play("walk-back-3-unarmed")
  else:
    velocity.x = lerpf(velocity.x, 0.0, 0.5)
  
  #if is_on_floor() and Input.is_action_just_pressed("Jump"):
    #var energy_to_jump = GM.player.energy_to_jump()
    #if GM.player.spend_energy(energy_to_jump):
      #velocity.y = GM.player.v0()
  

  if is_on_floor():
    # Если кнопка только нажата, начинаем зарядку
    if Input.is_action_just_pressed("Jump"):
      charged_jump_energy = 0  # Сбрасываем зарядку прыжка
      GM.player.jump_timer.start()
    
    # Если кнопка удерживается, увеличиваем заряд
    elif Input.is_action_pressed("Jump") and GM.player.jump_timer.is_stopped():
      var chargebar = GM.ui.get_node("%ChargedJump")
      var energy_to_charged_jump = GM.player.energy_to_jump() * 3
      chargebar.visible = true
      chargebar.value = (charged_jump_energy / energy_to_charged_jump)*100
      if charged_jump_energy < energy_to_charged_jump and GM.player.spend_energy(2, false):  # Тратим энергию для зарядки
        charged_jump_energy += 1  # Увеличиваем заряд энергии

    # Если кнопка отпущена до зарядки максимума, выполняем обычный прыжок
    elif Input.is_action_just_released("Jump"):
      GM.player.jump_timer.stop()
      var chargebar = GM.ui.get_node("%ChargedJump")
      var energy_to_charged_jump = GM.player.energy_to_jump() * 3
      chargebar.visible = false
      chargebar.value = 0
      if charged_jump_energy >= energy_to_charged_jump:  # Если есть зарядка
        $Effects/SparksElec.emitting = true
        velocity.y = GM.player.v0() * charged_jump_power  # Усиленный прыжок
        charged_jump_energy = 0  # Сбрасываем зарядку после прыжка
        chargebar.visible = false
      else:
        GM.player.energy = min(GM.player.energy+charged_jump_energy, GM.player.max_energy)
        if GM.player.spend_energy(GM.player.energy_to_jump(), true):
          velocity.y = GM.player.v0()
        else:
          GM.ui.say(preload("res://data/dialogues/not_enough_energy_and_stamina.tres"))
    
  
  if not is_on_floor():
    velocity.y += gravity
    #$Character/Body.play("jump-3-unarmed")
  
  # look to action forward / back
  #if not Input.is_anything_pressed():
    #velocity.x = lerpf(velocity.x, 0.0, 0.5)
  
  if Input.is_action_pressed("Fire"):
    if GM.ui.selected_slot != 0:
      if not GM.weapon.single_fire_lock:
        GM.weapon.fire()
  if Input.is_action_just_released("Fire"):
    GM.weapon.single_fire_lock = false


  if Input.is_action_just_pressed("Special"):
    GM.weapon.start_target_lock()

  elif Input.is_action_pressed("Special"):
    GM.weapon.process_target_lock()

  if Input.is_action_just_released("Special"):
    if not GM.weapon.locked_target:
      GM.weapon.reset_target_lock()



  #if GM.weapon.weapon and GM.weapon.weapon.mag == 0 and ADB.get_ammo(GM.weapon.weapon.ammo_type).amount > 0:
    #$Label.text = "I have to reload!"
  #elif GM.weapon.weapon and GM.weapon.weapon.mag == 0 and ADB.get_ammo(GM.weapon.weapon.ammo_type).amount == 0:
    #$Label.text = "Time to tear'em with claws! *BARK*"
  #else:
    #$Label.text = "%.3d kg %s" % [GM.player.weight(), weapon_weight_mod]
  
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
  if is_on_floor() and not is_zero_approx(velocity.x) \
  and velocity.x * view_direction > 0.1 * view_direction:
    $Character/Body.play("walk_forward_%s_%s" % [pregnancy_stage, body_animation])
  if is_on_floor() and not is_zero_approx(velocity.x)\
  and velocity.x * view_direction < 0.1 * -view_direction:
    $Character/Body.play("walk_back_%s_%s" % [pregnancy_stage, body_animation])
  if is_on_floor() and is_zero_approx(velocity.x) \
  and $Character/Body.animation != "wait_1_%s_%s" % [pregnancy_stage, body_animation]:
    $Character/Body.play("wait_1_%s_%s" % [pregnancy_stage, body_animation])
  if not is_on_floor() and abs(velocity.y) > 0.1:
    $Character/Body.play("jump_%s_%s" % [pregnancy_stage, body_animation])

  
  recoil_position.x = recoil_position.x * view_direction
  #if abs(recoil_position.x) < 0.1:
    #recoil_position.x = 0.0
  #if abs(recoil_position.y) < 0.1:
    #recoil_position.y = 0.0
  if is_zero_approx(recoil_position.x):
    recoil_position.x = 0.0
  if is_zero_approx(recoil_position.y):
    recoil_position.y = 0.0
  if abs(recoil_position) > Vector2(0.1, 0.1):
    global_position = global_position + lerp(Vector2.ZERO, recoil_position, weapon_weight_mod)
  
  move_and_slide()

func charge_jump(_delta) -> void:
  pass

func cancel_charged_jump() -> void:
  GM.player.energy = min(GM.player.energy + charged_jump_energy * 0.5, GM.player.max_energy)
  GM.ui.get_node("%ChargeBar").visible = false
  jump_charged = false
  charged_jump_energy = 0.0


func adjust_speed(speed) -> float:
  var a_speed: float
  a_speed = (speed / (0.5 + pow(GM.player.weight() / (weight_base), 2))) + 100
  # Убедимся, что скорость не уходит совсем
  return max(a_speed, base_speed / 10)


func heavy_weapon() -> float:
  var weapon = GM.weapon.weapon
  if not weapon:
    return 0.7
  else:
    var weapon_weight = weapon.weight + ADB.get_ammo(weapon.ammo_type).cartridge_weight * weapon.mag
    var mf = (1 / (weapon_weight + 2.0)) + 0.05
    return mf


func sine_move(frame: int, total_frames: int, max_vector: Vector2) -> Vector2:
  frame = frame % total_frames
  var angle = float(frame) / float(total_frames) * PI
  var sin_scale = sin(angle)
  return Vector2(sin_scale * max_vector.x, sin_scale * max_vector.y)


func _on_weapon_offset_changed(value) -> void:
  $ArmsPivot/Arms/Weapon.position = Vector2(30, -5) + value

func _on_view_direction_changed(vd) -> void:
  if vd == -1:
    if not $Character/Body.flip_h:
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
  walk_speed_mod = walk_speed_mod_max * sin((float($Character/Body.frame) / float(max_frames)) * 2*PI)
  # footprints
  if $Character/Body.frame in [3, 7] \
  and abs(velocity.x) > 1.0 \
  and is_on_floor():
    var footprint = footprint_scene.instantiate()
    var step_sound = GM.audio.get_random_sound("step_basic")
    footprint.global_position = global_position + Vector2(13*view_direction, 52)
    GlobalFx.add_decal(footprint)
    GM.audio.add_sfx(step_sound, global_position, {
      "volume_db": -5.0,
      "pitch_scale": 0.8,
      "pitch_random": 0.2
    })
  
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


func _on_pregnancy_stage_changed(value) -> int:
  if value == 5:
    GM.player.hp_restore = 50.0
    GM.player.stamina_restore = 1.0
    GM.ui.say(load("res://data/dialogues/im_too_heavy.tres"))
  else:
    GM.player.hp_restore = 10.0
    GM.player.stamina_restore = 10.0
  var stage = clampi(value, 0, 5)
  GM.player.max_hp = 200 + 25*stage
  return stage
