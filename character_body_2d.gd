extends CharacterBody2D

@export var footprint_scene: PackedScene  # Сцена следа
@export var tracked_frames: Array = [11, 2]  # Кадры, на которых создаются следы
var speed : float = 240.0
var jump_velocity : float = -400.0
var state : String = "stand"
var prev_state = state
var gravity : float = 981.0
var gun_angle : float = deg_to_rad(45)
var direction
var selected_weapon = "dummy"
var weapon_animations = ["default", "default", "default"]
var weapon_cooldown = 0.2
var weapon_reload = 1.0
var weapon_ready = true
var weapon_damage = 0
var weapon_mag_size = 1
var weapon_mag = 1
var weapon_auto = true
var weapon_recoil_deg = 0.0
var weapon_recoil_linear = 0.0
var current_recoil_deg = 0.0
var weapon_lock_time = 0.0
var weapon_heat = 0.0
var weapon_heat_by_shot = 5.0
var weapon_cooldown_per_pf = 0.1
var weapon_heat_max = 100.0
var locking_timer = 0.0
var target_locked = false
var target_lock_marker
var dress_frames = {
  "nude": preload("res://assets/sprites/vega-nude.tres"),
  "training": preload("res://assets/sprites/vega-training.tres")
}
var rocket_scene = preload("res://mini_rocket.tscn")
var weapon_mag_scene = preload("res://weapon_mag.tscn")
var bullet_scene = preload("res://bullet.tscn")
var casing_scene = preload("res://casing.tscn")
var smartshell_scene = preload("res://smart_shell.tscn")
var marker_scene = preload("res://marker.tscn")
var damage_text_scene = preload("res://damage_text.tscn")
@onready var body_sprite = %CharacterSprites/Body
@onready var arm_near_sprite = %ArmSprites/ArmNear
@onready var arm_far_sprite = %ArmSprites/ArmFar
var footprint_frame: int
var zoom_level = 1.0
@export var max_hp: int = 100
var hp: int = max_hp
var is_dead: bool = false

const D90 = deg_to_rad(90)
const D180 = deg_to_rad(180)


func frames_duration(sprite: AnimatedSprite2D, animation_name: String) -> float:
    var frame_count = sprite.sprite_frames.get_frame_count(animation_name)
    var fps = sprite.sprite_frames.get_animation_speed(animation_name)
    return frame_count / fps

func arms_point(state:String, direction:Variant) -> Vector2:
  var point = Vector2.ZERO
  if is_instance_of(direction, TYPE_VECTOR2) or is_instance_of(direction, TYPE_VECTOR2I):
    direction = sign(direction.x)
  else:
    direction = sign(direction)
  match state:
    "stand":
      point = Vector2(4, -12)
    "crouch":
      point = Vector2(6, 7)
    "jump":
      point = Vector2(4, -16)
    "hit":
      point = Vector2(4, -12)
    _:
      point = Vector2.ZERO
  point.x = point.x * direction
  return point

func _ready() -> void:
  #Input.set_custom_mouse_cursor(null)
  body_sprite.connect("frame_changed", _on_frame_changed)
  Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
  set_process_input(true)
  select_weapon("dummy")
  state = "stand"
  $ArmsPivot.position = arms_point(state, 1)
  %UI/UIHealthBar.hp = hp
  %UI/UIHealthBar.max_hp = max_hp


func _process(delta: float) -> void:
  var cursor = $Cursor
  var arms = $ArmsPivot
  
  # Обновляем позицию курсора
  cursor.position = get_global_mouse_position()
  
  # Cursor change on enemy hover
  #var overlapping_areas = $Cursor/Area2D.get_overlapping_areas()
  #if $Cursor.animation != "aim":
    #if overlapping_areas:
      #for area in overlapping_areas:
        #if area.is_in_group("enemies"):
          #$Cursor.play("aim")
          #return
  #else:
    #if not overlapping_areas:
      #$Cursor.play("default")
  #elif $Cursor.animation != "default":
    #$Cursor.play("default")
  
  var min_angle = -gun_angle
  var max_angle = gun_angle
  var target_position = get_global_mouse_position()
  # Freeze direction while firing HMG
  #if not(selected_weapon == "mg" and Input.is_action_pressed("FirePrimary")):
    #direction = (target_position - global_position).normalized()
  direction = (target_position - global_position).normalized()
  
  if target_position.x < global_position.x:
    body_sprite.flip_h = true
    $ArmsPivot.scale.x = -1  # Разворачиваем ArmsPivot по оси X
    $CollisionShape2D.transform.x *= -1
    if rad_to_deg(direction.angle()) > 0:
      arms.rotation = max(max_angle+D90, direction.angle()) + D180
    else:
      arms.rotation = min(min_angle-D90, direction.angle()) + D180
  else:
    body_sprite.flip_h = false
    $ArmsPivot.scale.x = 1
    arms.rotation = clamp(direction.angle(), min_angle, max_angle)
  $ArmsPivot.position = arms_point(state, direction)
  arms.rotation -= deg_to_rad(current_recoil_deg)*sign(direction.x)
  if Input.is_action_just_pressed("Super1"):
    change_dress("nude")
  if Input.is_action_just_pressed("Super2"):
    change_dress("training")
  
  # Camera Motion
  $Camera.offset = lerp($Camera.offset, to_local(target_position)/3, 0.05)
  
  # Zoom
  if Input.is_action_just_pressed("ZoomIn"):
    match zoom_level:
      1.0:
        zoom_level = 1.25
      0.75:
        zoom_level = 1.0
      _:
        pass
  if Input.is_action_just_pressed("ZoomOut"):
    match zoom_level:
      1.25:
        zoom_level = 1.0
      1.0:
        zoom_level = 0.75
      _:
        pass
  $Camera.zoom = lerp($Camera.zoom, Vector2(zoom_level, zoom_level), 0.1)

func _physics_process(delta: float) -> void:
  var cursor = $Cursor
  # Обработка ввода и обновление анимации
  if weapon_auto:
    if Input.is_action_pressed("FirePrimary"):
      if weapon_ready:
        fire_weapon()
  else:
    if Input.is_action_just_pressed("FirePrimary"):
      if weapon_ready:
        fire_weapon()
      else:
        print("reloading")
  if Input.is_action_just_released("FirePrimary") and selected_weapon == "mg":
    $ArmsPivot/WeaponSprite/FlashSprite.visible = false

  # recoil cooldown
  current_recoil_deg = lerpf(current_recoil_deg, 0.0, 0.1)
  
  if Input.is_action_just_pressed("Aim") and selected_weapon == "smartgun":
    $Cursor.play("lock_smartgun")
  if Input.is_action_pressed("Aim") and selected_weapon == "smartgun":
    if locking_timer >= weapon_lock_time:
      target_locked = true
      locking_timer = 0.0
      %Sfx/GlobalSoundPlayer.stream.set_initial_clip(1)
      %Sfx/GlobalSoundPlayer.playing = true
      lock_target()
    else:
      %Sfx/GlobalSoundPlayer.stream.set_initial_clip(2)
      %Sfx/GlobalSoundPlayer.playing = true
      locking_timer += delta
  if Input.is_action_just_released("Aim") and selected_weapon == "smartgun" and locking_timer < weapon_lock_time:
    $Cursor.play("aim_smartgun")
    %Sfx/GlobalSoundPlayer.stream.set_initial_clip(0)
    %Sfx/GlobalSoundPlayer.playing = true
    locking_timer = 0.0
  if Input.is_action_just_pressed("Aim") and selected_weapon == "smartgun" and target_locked:
    if target_lock_marker and is_instance_valid(target_lock_marker):
      target_lock_marker.queue_free()
    target_locked = false
    %Sfx/GlobalSoundPlayer.stream.set_initial_clip(0)
    %Sfx/GlobalSoundPlayer.playing = true
  if selected_weapon != "smartgun" and target_locked:
    if target_lock_marker and is_instance_valid(target_lock_marker):
      target_lock_marker.queue_free()
    target_locked = false
  # HMG Laser Sight
  if Input.is_action_just_pressed("Aim") and selected_weapon == "mg":
    if %LaserSightPL.enabled == false:
      %LaserSightPL.enabled = true
    else:
      %LaserSightPL.enabled = false
  if selected_weapon not in ["mg"]:
    %LaserSightPL.enabled = false

    
  # Гравитация
  if not is_on_floor():
    velocity.y += gravity * delta

  # Обработка движения персонажа
  velocity.x = 0

  # Ходьба назад
  if Input.is_action_pressed("Left") and \
    not Input.is_action_pressed("Sprint"):
    if sign(direction.x) > 0:
      velocity.x = -speed * 0.25
      if is_on_floor():
        if state == "crouch":
          velocity.x = -speed * 0.15
          body_sprite.play("crouch-back")
        else:
          body_sprite.play("walk-back")
    else:
      velocity.x = -speed
      if is_on_floor():
        if state == "crouch":
          velocity.x = -speed * 0.3
          body_sprite.play("crouch-forward")
        else:
          body_sprite.play("walk-forward")
    
  elif Input.is_action_pressed("Right") and \
    not Input.is_action_pressed("Sprint"):
    if sign(direction.x) > 0:
      velocity.x = speed
      if is_on_floor():
        if state == "crouch":
          velocity.x = speed * 0.3
          body_sprite.play("crouch-forward")
        else:
          body_sprite.play("walk-forward")
    else:
      if is_on_floor():
        if state == "crouch":
          velocity.x = speed * 0.15
          body_sprite.play("crouch-back")
        else:
          velocity.x = speed * 0.25
          body_sprite.play("walk-back")

  # Спринт, если зажата кнопка спринта
  if Input.is_action_pressed("Sprint") and is_on_floor():
    if sign(direction.x) > 0:
      velocity.x = speed * 2
    else:
      velocity.x = -speed * 2
    if body_sprite.animation == "dash":
      pass
    else:
      body_sprite.play("dash")
  
  if Input.is_action_just_pressed("CrouchToggle"):
    if state == "crouch":
      state = "stand"
      body_sprite.play("stand")
    else:
      state = "crouch"
      body_sprite.play("crouch-static")
  
  if not Input.is_anything_pressed() and is_on_floor():
    match state:
      "crouch":
        body_sprite.play("crouch-static")
      "stand":
        body_sprite.play("stand")
      "hit":
        pass
      _:
        state = "stand"

  
  if not is_on_floor():
    body_sprite.play("jump")
    state = "jump"
  %UI/Debug.text = "previous state %s\ncurrent state %s" % [prev_state, state]
  # Прыжок
  if is_on_floor() and Input.is_action_just_pressed("Jump"):
    velocity.y = jump_velocity
  
  if Input.is_action_just_pressed("Weapon1"):
    select_weapon("smartgun")
  
  if Input.is_action_just_pressed("Weapon2"):
    select_weapon("laser_rifle")
  
  if Input.is_action_just_pressed("Weapon3"):
    select_weapon("handstarter")
  
  if Input.is_action_just_pressed("Weapon4"):
    select_weapon("mg")
  
  if Input.is_action_just_pressed("Item1"):
    take_damage(randi_range(1, 10))
    
  if Input.is_action_just_pressed("Item2"):
    %UI/UISay.portrait = "default"
    %UI/UISay.who = "Unknown Contact"
    %UI/UISay.what = "Для Siemens S10, который был одним из первых телефонов с цветным экраном:

Экран имел разрешение 97×54 пикселя.
Пропорции были близки к 16:9, но фактическая форма экрана была чуть менее вытянутой."
    %UI/UISay.steps = 60
    %UI/UISay.display_time = 5
    %UI/UISay.say()
  
  if Input.is_action_just_pressed("Item3"):
    %UI/UISay.portrait = "vega-angry"
    %UI/UISay.who = "Vega"
    %UI/UISay.what = "What do you want?!"
    %UI/UISay.steps = 5
    %UI/UISay.display_time = 2
    %UI/UISay.say()
  
  # Weapon heating and cooling
  weapon_heat = clampf(weapon_heat - weapon_cooldown_per_pf, 0, weapon_heat_max*2)
  %UI/UIHeat.heat = weapon_heat
  #if weapon_heat > weapon_heat_max:
    #if randi_range(0, 10) == 0:
      #take_damage(1)
  if weapon_heat > weapon_heat_max / 2:
    $ArmsPivot/RayCast2D/HeatSmoke.emitting = true
    $ArmsPivot/RayCast2D/HeatSmoke.process_material.initial_velocity_max = weapon_heat
    $ArmsPivot/RayCast2D/HeatSmoke.process_material.initial_velocity_min = weapon_heat / 4
    $ArmsPivot/RayCast2D/HeatSmoke.process_material.scale_max = (2 - (weapon_heat_max / (weapon_heat + 1))) * 0.25
    $ArmsPivot/RayCast2D/HeatSmoke.amount_ratio = weapon_heat_max / (weapon_heat + 1)
    
  else:
    $ArmsPivot/RayCast2D/HeatSmoke.emitting = false
  
  # Применение движения
  move_and_slide()

func lock_target():
  if $Cursor/TargetArea.get_overlapping_bodies():
    var target = $Cursor/TargetArea.get_overlapping_bodies()[0]
    target_lock_marker = marker_scene.instantiate()
    target.add_child(target_lock_marker)
    target_lock_marker.play("smartgun_lock")


func select_weapon(weapon: String) -> Array:
  # array is animation names for still, firing, reloading
  var animations
  match weapon:
    "dummy":
      animations = ["default", "default", "default"]
      %UI/LabelWeapon.text = "DUMMY"
      $Cursor.play("aim_dummy")
      arm_far_sprite.play("arm-far-pistol")
      arm_near_sprite.play("arm-near-pistol")
      $ArmsPivot/WeaponSprite.position = Vector2(32, -8)
      $ArmsPivot/RayCast2D.position = Vector2(46, -13)
      weapon_cooldown = 0.025
      weapon_reload = 1.0
      weapon_damage = 0
      weapon_mag_size = 10
      weapon_mag = weapon_mag_size
      weapon_auto = true
      weapon_recoil_deg = 5
      weapon_recoil_linear = 10
      current_recoil_deg = 0
    "smartgun":
      animations = ["smartgun_still", "smartgun_fire", "smartgun_reload"]
      %UI/LabelWeapon.text = "光星12型燕 Smart Pistol"
      $Cursor.play("aim_smartgun")
      arm_far_sprite.play("arm-far-pistol")
      arm_near_sprite.play("arm-near-pistol")
      $ArmsPivot/WeaponSprite.position = Vector2(32, -8)
      $ArmsPivot/WeaponSprite/FlashSprite.position = Vector2(43, 1)
      $ArmsPivot/WeaponSprite/FlashSprite.play("smartgun")
      $ArmsPivot/RayCast2D.position = Vector2(57, -12)
      weapon_cooldown = 0.4
      weapon_reload = 1.5
      weapon_damage = 15
      weapon_mag_size = 10
      weapon_mag = 10
      weapon_auto = false
      weapon_recoil_deg = 5
      weapon_recoil_linear = 0
      current_recoil_deg = 0
      weapon_lock_time = 1.0
      $ArmsPivot/FlashLight.blink_on_time = weapon_cooldown / 2
      $ArmsPivot/FlashLight.blink_off_time = weapon_cooldown / 2
      $ArmsPivot/FlashLight.max_energy = 0.4
      $ArmsPivot/FlashLight.min_energy = 0.0
      $ArmsPivot/FlashLight.scale = Vector2(1.5, 3)
    "laser_rifle":
      animations = ["laser_rifle_still", "laser_rifle_fire", "laser_rifle_reload"]
      %UI/LabelWeapon.text = "Laser Rifle Prototype"
      $Cursor.play("aim_dummy")
      arm_far_sprite.play("arm-far-rifle")
      arm_near_sprite.play("arm-near-rifle")
      $ArmsPivot/WeaponSprite.position = Vector2(18, 1)
      $ArmsPivot/RayCast2D.position = Vector2(44, -6)
      weapon_cooldown = 0.05
      weapon_reload = 0.8
      weapon_damage = 10
      weapon_mag_size = 3
      weapon_mag = 3
      weapon_auto = false
      weapon_recoil_deg = 0.5
      weapon_recoil_linear = 0
      current_recoil_deg = 0
      $ArmsPivot/FlashLight.max_energy = 1.0
      $ArmsPivot/FlashLight.min_energy = 0.0
      $ArmsPivot/FlashLight.blink_on_time = 0.33
      $ArmsPivot/FlashLight.scale = Vector2(16, 8)
    "handstarter":
      animations = ["handstarter_still", "handstarter_still", "handstarter_reload"]
      %UI/LabelWeapon.text = "Handstarter Rapier II"
      $Cursor.play("aim_handstarter")
      arm_far_sprite.play("arm-far-pistol")
      arm_near_sprite.play("arm-near-pistol")
      $ArmsPivot/WeaponSprite.position = Vector2(47, -7)
      $ArmsPivot/RayCast2D.position = Vector2(47, -9)
      weapon_cooldown = 0.15
      weapon_reload = 1.2
      weapon_damage = 25
      weapon_mag_size = 8
      weapon_mag = 8
      weapon_auto = true
      weapon_recoil_deg = 3.5
      weapon_recoil_linear = 0
      current_recoil_deg = 0
    "mg":
      animations = ["mg_still", "mg_fire", "mg_reload"]
      %UI/LabelWeapon.text = "Assault HMG"
      $Cursor.play("default")
      arm_far_sprite.play("arm-far-rifle")
      arm_near_sprite.play("arm-near-rifle")
      $ArmsPivot/WeaponSprite.position = Vector2(30, 1)
      $ArmsPivot/WeaponSprite/FlashSprite.position = Vector2(28, -4)
      $ArmsPivot/WeaponSprite/FlashSprite.play("mg")
      $ArmsPivot/RayCast2D.position = Vector2(58, -4)
      weapon_cooldown = 0.1
      weapon_reload = 1.8
      weapon_damage = 12
      weapon_mag_size = 16
      weapon_mag = 16
      weapon_auto = true
      weapon_recoil_deg = 9.5
      weapon_recoil_linear = 6
      current_recoil_deg = 0
      $ArmsPivot/FlashLight.blink_on_time = weapon_cooldown / 2
      $ArmsPivot/FlashLight.blink_off_time = weapon_cooldown / 2
      $ArmsPivot/FlashLight.max_energy = 0.9
      $ArmsPivot/FlashLight.min_energy = 0.0
      $ArmsPivot/FlashLight.scale = Vector2(1.5, 3)
    _:
      animations = ["default", "default", "default"]
  selected_weapon = weapon
  weapon_animations = animations
  $ArmsPivot/WeaponSprite.play(animations[0])
  %UI/UIAmmo.ammo = weapon_mag
  %UI/UIAmmo.ammo_max = weapon_mag_size
  %UI/UIAmmo.weapon = selected_weapon
  return animations

func fire_weapon():
  if state == "hit":
    return
  # Play firing animation
  $ArmsPivot/WeaponSprite.play(weapon_animations[1])
  # Weapon logic called here
  match selected_weapon:
    "dummy":
      %UI/Status.text = "PEW"
      $ArmsPivot/WeaponSoundPlayer.stream.set_initial_clip(2)
      $ArmsPivot/WeaponSoundPlayer.playing = true
    "laser_rifle":
      weapon_mag -= 1
      $ArmsPivot/WeaponSoundPlayer.stream.set_initial_clip(1)
      $ArmsPivot/WeaponSoundPlayer.playing = true
      fire_laser()
    "handstarter":
      weapon_mag -= 1
      fire_mrl()
    "mg":
      weapon_mag -= 1
      $ArmsPivot/WeaponSoundPlayer.stream.set_initial_clip(0)
      $ArmsPivot/WeaponSoundPlayer.playing = true
      fire_mg()
    "smartgun":
      weapon_mag -= 1
      $ArmsPivot/WeaponSoundPlayer.stream.set_initial_clip(3)
      $ArmsPivot/WeaponSoundPlayer.playing = true
      fire_smartgun()
    _:
      print("Nothing to pew")
  weapon_heat += weapon_heat_by_shot
  var recoil_modifier = 1.0
  match state:
    "stand":
      recoil_modifier = 1.0
    "jump":
      recoil_modifier = 2.0
    "crouch":
      recoil_modifier = 0.33
  current_recoil_deg = lerpf(
      current_recoil_deg,
      current_recoil_deg+weapon_recoil_deg*recoil_modifier,
      1.0
    )
  position = lerp(
    position,
    position - Vector2(weapon_recoil_linear * sign(direction.x), 0),
    0.9)
  if weapon_recoil_linear > 3 and current_recoil_deg > 4 and is_on_floor():
    if state == "crouch":
      $CharacterSprites/Body.play("recoil-crouch")
    else:
      $CharacterSprites/Body.play("recoil")
  # Firing delay
  #%UI/LabelMag.text = str(weapon_mag)
  %UI/UIAmmo.ammo = weapon_mag
  weapon_ready = false
  if weapon_mag > 0:
    %UI/Status.text = "COOLDOWN"
    $ReloadTimer.wait_time = weapon_cooldown
    $ReloadTimer.start()
    await $ReloadTimer.timeout
  else:
    # Wait for fire animation to end and play reload
    $ArmsPivot/WeaponSprite/FlashSprite.visible = false
    $ReloadTimer.wait_time = frames_duration($ArmsPivot/WeaponSprite, weapon_animations[1])
    $ReloadTimer.start()
    await $ReloadTimer.timeout
    var previous_cursor = $Cursor.animation
    match selected_weapon:
      "handstarter":
        $Cursor.play("reload_handstarter")
        var empty_mag = weapon_mag_scene.instantiate()
        empty_mag.position = $ArmsPivot/WeaponSprite.global_position
        empty_mag.set_weapon("handstarter")
        GlobalFx.add_debris(empty_mag)
      "mg":
        $Cursor.play("reload_default")
        var empty_mag = weapon_mag_scene.instantiate()
        empty_mag.position = $ArmsPivot/WeaponSprite.global_position
        empty_mag.set_weapon("mg")
        GlobalFx.add_debris(empty_mag)
      _:
        $Cursor.play("reload_default")
    $Cursor.speed_scale = 1 / weapon_reload
    %UI/Status.text = "RELOAD"
    $ArmsPivot/WeaponSprite.play(weapon_animations[2])
    $ReloadTimer.wait_time = weapon_reload
    $ReloadTimer.start()
    await $ReloadTimer.timeout
    # Play still animation
    $Cursor.play(previous_cursor)
    $Cursor.speed_scale = 1.0
    weapon_mag = weapon_mag_size
    %UI/UIAmmo.ammo = weapon_mag
  %UI/Status.text = ""
  $ArmsPivot/WeaponSprite.play(weapon_animations[0])
  weapon_ready = true


func change_dress(dress):
  body_sprite.frames = dress_frames[dress]
  arm_far_sprite.frames = dress_frames[dress]
  arm_near_sprite.frames = dress_frames[dress]

func get_armor_type(ray: RayCast2D) -> String:
  var target_shape_id = ray.get_collider_shape()
  var collider = ray.get_collider()
  if collider and collider is CollisionObject2D:
    # Получаем индекс владельца формы
    var shape_owner_index = collider.shape_find_owner(target_shape_id)
    # Проверяем, существует ли владелец
    if shape_owner_index != -1:
      # Получаем узел-владелец формы
      var zone = collider.shape_owner_get_owner(shape_owner_index)
      # Проверяем наличие метаданных
      if zone and zone.has_meta("armor"):
        return zone.get_meta("armor")
  return "none"

func fire_smartgun() -> void:
  var ray = $ArmsPivot/RayCast2D
  var p0 = ray.global_position
  var smartshell_instance = smartshell_scene.instantiate()
  smartshell_instance.direction = direction
  smartshell_instance.position = p0
  smartshell_instance.rotation = $ArmsPivot.rotation
  if target_lock_marker and is_instance_valid(target_lock_marker):
    smartshell_instance.target_global = target_lock_marker.global_position
  smartshell_instance.target_locked = target_locked
  GlobalFx.add_fx(smartshell_instance)
  $ArmsPivot/FlashLight.light_once("blink", weapon_cooldown)
  
  $ArmsPivot/WeaponSprite/FlashSprite.visible = true
  await get_tree().create_timer(0.5).timeout
  $ArmsPivot/WeaponSprite/FlashSprite.visible = false

func fire_mg() -> void:
  var ray = $ArmsPivot/RayCast2D
  var p0 = ray.global_position
  var bullet_instance = bullet_scene.instantiate()
  bullet_instance.direction = direction
  bullet_instance.position = p0
  bullet_instance.rotation = $ArmsPivot.rotation
  bullet_instance.damage = weapon_damage
  if state == "crouch":
    bullet_instance.spread = 50
  else:
    bullet_instance.spread = 75
  GlobalFx.add_fx(bullet_instance)
  $ArmsPivot/FlashLight.light_once("blink", weapon_cooldown)
  var casing_instance = casing_scene.instantiate()
  casing_instance.direction = direction
  casing_instance.position = p0
  casing_instance.rotation = randf_range(-1, 1)
  GlobalFx.add_debris(casing_instance)
  if Input.is_action_pressed("FirePrimary"):
    $ArmsPivot/WeaponSprite/FlashSprite.visible = true

  

func fire_mrl() -> void:
  var rocket_instance = rocket_scene.instantiate()
  rocket_instance.direction = direction
  var ray = $ArmsPivot/RayCast2D
  var p0 = ray.global_position
  rocket_instance.position = p0
  rocket_instance.rotation = $ArmsPivot.rotation - deg_to_rad(8)*direction.x
  GlobalFx.add_fx(rocket_instance)

func fire_laser() -> void:
  var ray = $ArmsPivot/RayCast2D
  ray.force_raycast_update()
  var p0 = ray.global_position
  var p1
  var target
  var armor_type = "default"
  var armor_rating = 1.0
  if ray.is_colliding():
    p1 = ray.get_collision_point()
    target = ray.get_collider()
    armor_type = get_armor_type(ray)
    match armor_type:
      "rubber":
        armor_rating = 0.5
      "rha":
        armor_rating = 3.0
    if target and target.has_method("take_damage"):  # Проверяем наличие метода take_damage
      target.take_damage(weapon_damage / armor_rating)
  else:
    p1 = p0 + ray.to_local(ray.target_position).normalized() * 2500
    print("MISS")
  var distance = p0.distance_to(p1)
  var sprite_interval = 32.0  # Расстояние между спрайтами (можно настроить)
  var num_sprites = int(distance / sprite_interval)
  for i in range(num_sprites):
    var t = float(i) / float(num_sprites)
    var position = p0.lerp(p1, t)
    var laser_instance = $LaserSprite.duplicate() as AnimatedSprite2D
    laser_instance.play("default")
    laser_instance.visible = true
    laser_instance.position = position
    laser_instance.rotation = (p1 - p0).angle()
    laser_instance.z_index = 1
    laser_instance.add_to_group("lasers")
    GlobalFx.add_fx(laser_instance)
  var hit_instance = $LaserHit.duplicate() as AnimatedSprite2D
  hit_instance.visible = true
  var surface_normal = ray.get_collision_normal()
  hit_instance.rotation = surface_normal.angle() + D180
  hit_instance.z_index = 2
  GlobalFx.add_decal(hit_instance, target)
  #hit_instance.add_to_group("hit_marks")
  #target.add_child(hit_instance)
  match armor_type:
    "rha":
      hit_instance.play("armor")
    "rubber":
      hit_instance.play("rubber")
    _:
      hit_instance.play("default")
  hit_instance.position = target.to_local(p1)
  $ArmsPivot/FlashLight.light_once("sine", 0.2)
  #$ArmsPivot/PointLight2D.enabled = true
  #await get_tree().create_timer(0.25).timeout
  #$ArmsPivot/PointLight2D.enabled = false
  await get_tree().create_timer(0.5).timeout
  get_tree().call_group("lasers", "queue_free")
  #await get_tree().create_timer(5).timeout
  ##get_tree().call_group("hit_marks", "queue_free")
  #hit_instance.queue_free()

func spawn_footprint():
  # Создаём след
  var footprint = footprint_scene.instantiate()
  match footprint_frame:
    2:
      footprint.global_position = global_position + Vector2(-7, 53)
    11:
      footprint.global_position = global_position + Vector2(19, 48)
  GlobalFx.add_decal(footprint)

func _on_frame_changed():
  # Проверяем, текущий ли кадр соответствует кадрам для следов
  if is_on_floor() and body_sprite.frame in tracked_frames:
    footprint_frame = body_sprite.frame
    spawn_footprint()

func take_damage(amount: int) -> int:
  if state == "crouch":
    amount = int(ceil(amount * 0.75))
  if is_dead:
    return 0
  else:
    var damage_text = damage_text_scene.instantiate()
    damage_text.theme.default_font_size = 28
    damage_text.float_distance = 100
    damage_text.text = "-%d" % amount
    damage_text.global_position = global_position + Vector2(0, -20)
    get_tree().current_scene.add_child(damage_text)
  prev_state = state
  state = "hit"
  hp -= amount
  %UI/UIHealthBar.hp = hp
  velocity.x = lerpf(velocity.x, 0.0, 0.5)
  var hit_animation = [
    "hit-1", "hit-2"
  ].pick_random()
  $CharacterSprites/Body.play(hit_animation)
  if hp <= 0:
    is_dead = true
  return min(hp, 0)



func reparent_object(object: Node2D, new_parent: Node2D) -> void:
  # Сохраняем глобальную позицию объекта
  var global_pos = object.global_position
  
  # Удаляем объект у текущего родителя
  object.get_parent().remove_child(object)
  
  # Добавляем объект к новому родителю
  new_parent.add_child(object)
  
  # Восстанавливаем глобальную позицию
  object.global_position = global_pos


func _on_body_animation_finished() -> void:
  if $CharacterSprites/Body.animation in [
    "hit-1", "hit-2"
  ]:
    state = prev_state
