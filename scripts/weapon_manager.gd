extends Node

var _weapon: Weapon
@export var weapon: Weapon:
  get:
    return _weapon
  set(value):
    _on_weapon_change(value)


var _fire_mode: String
@export var fire_mode: String:
  get:
    return _fire_mode
  set(value):
    _on_mode_change(value)


func _on_weapon_change(value) -> void:
  _weapon = value
  GM.ui.ammobar.update()
  if value:
    if GM.in_safe_area:
      fire_mode = "safe"
    else:
      fire_mode = value.get_fire_modes()[1]
    if value.mag > 0:
      can_fire = true
  GM.ui.firemode.update()

func _on_mode_change(value) -> void:
  _fire_mode = value
  GM.ui.firemode.mode = value
  GM.ui.firemode.update()

var can_fire: bool
var single_fire_lock: bool
var linear_recoil_counter: int = 0
var angular_recoil_counter: int = 0
var spread: float = 0.0

func fire() -> void:
  if not $WeaponTimer.is_stopped():
    return
  if weapon and can_fire and weapon.mag > 0:
    match fire_mode:
      "single":
        fire_single()
        single_fire_lock = true
      "full_auto":
        fire_auto()
      "burst":
        fire_burst()
        single_fire_lock = true
      _:
        return
  #else:
    #if weapon.mag == 0:
      #reload()
    #else:
      #unjam()

func fire_auto() -> void:
  if not $WeaponTimer.is_stopped():
    return
  spread = deg_to_rad(weapon.spread_full_auto)
  perform_shot()
  $WeaponTimer.start(1.0 / weapon.rate_full_auto)

func fire_single() -> void:
  if not $WeaponTimer.is_stopped():
    return
  spread = deg_to_rad(weapon.spread_single)
  perform_shot()
  $WeaponTimer.start(1.0 / weapon.rate_single)

func fire_burst() -> void:
  if not $WeaponTimer.is_stopped():
    return
  spread = deg_to_rad(weapon.spread_burst)
  for i in range(weapon.burst_length):
    perform_shot()
    $WeaponTimer.start(1.0 / weapon.rate_burst)
    await $WeaponTimer.timeout


func perform_shot() -> void:
  weapon.set_mag(weapon.mag - min(weapon.cartridge_by_shot, weapon.mag))
  if weapon.can_be_chambered:
    weapon.is_chambered = true
  match weapon.hit_type:
    "hitscan":
      hitscan()
    "projectile":
      projectile()
    _:
      return
  if weapon.get_recoil_types():
    recoil()
  if weapon.casing_scene:
    eject_shell()
  if weapon.mag <= 0:
    can_fire = false
    weapon.set_mag(0)
    weapon.is_chambered = false
    #GM.ui.say(load("res://data/dialogues/vr_level/ammos_out.tres"))
  GM.ui.ammobar.update()

func recoil() -> void:
  linear_recoil_counter += 1
  angular_recoil_counter += 1
  var recoil_types = weapon.get_recoil_types()
  var vega = GM.player.vega
  if "linear" in recoil_types and linear_recoil_counter > weapon.shots_before_linear_recoil:
    if GM.player.spend_energy(weapon.linear_recoil.length_squared()):
      vega.recoil_position = weapon.linear_recoil
    else:
      vega.recoil_position = weapon.linear_recoil * 1.5
  if "angular" in recoil_types and angular_recoil_counter > weapon.shots_before_angular_recoil:
    if GM.player.spend_energy(weapon.angular_recoil**2):
      vega.recoil_angle -= deg_to_rad(weapon.angular_recoil)
    else:
      vega.recoil_angle -= deg_to_rad(weapon.angular_recoil) * 1.5
  $RecoilTimer.start(weapon.recoil_recover_delay)
  

func projectile() -> void:
  var ray = GM.player.vega.ray
  var arms_pivot = GM.player.vega.arms_pivot
  var projectile_instance = weapon.projectile_scene.instantiate()
  var p0 = ray.global_position
  projectile_instance.global_position = p0
  projectile_instance.global_rotation = arms_pivot.global_rotation + randf_range(-spread, spread)
  GlobalFx.add_fx(projectile_instance)


func hitscan() -> void:
  var ray = GM.player.vega.ray
  var arms_pivot = GM.player.vega.arms_pivot
  var hitscan_instance = weapon.hitscan_scene.instantiate()
  var hit_mark = weapon.hit_mark_scene.instantiate()
  var p0 = ray.global_position
  var p1 = p0 + Vector2(1024, 0).rotated(arms_pivot.global_rotation)
  var ray_r0 = ray.global_rotation
  ray.global_rotation += randf_range(-spread, spread)
  ray.force_raycast_update()
  if ray.is_colliding():
    var target = ray.get_collider()
    p1 = ray.get_collision_point()
  ray.global_rotation = ray_r0
  hitscan_instance.hit_point = p1
  hitscan_instance.points[0] = p0
  hitscan_instance.points[1] = p1
  GlobalFx.add_fx(hitscan_instance)
  hit_mark.global_position = p1
  GlobalFx.add_decal(hit_mark)
  

func reload() -> void:
  if not $WeaponTimer.is_stopped():
    return
  if weapon and ADB.get_ammo(weapon.ammo_type):
    if ADB.get_ammo(weapon.ammo_type).amount > 0:
      GM.player.weapon_sprite.play(weapon.reload_animation)
      if weapon.empty_clip_scene:
        var clip_instance = weapon.empty_clip_scene.instantiate()
        clip_instance.scale.x = GM.player.vega.view_direction
        clip_instance.global_position = GM.player.weapon_sprite.global_position
        clip_instance.rotation_degrees = randf_range(-30, 30)
        clip_instance.angular_velocity = randf_range(-15, 15)
        GlobalFx.add_debris(clip_instance)
      $WeaponTimer.start(weapon.reload_time)
      await $WeaponTimer.timeout
      var ammo_to_reload = min(weapon.mag_size, ADB.get_ammo(weapon.ammo_type).amount)
      if weapon.is_chambered:
        ammo_to_reload += 1
      weapon.set_mag(ammo_to_reload)
      ADB.get_ammo(weapon.ammo_type).use_ammo(ammo_to_reload)
      if weapon.is_chambered or not weapon.can_be_chambered:
        GM.player.weapon_sprite.play(weapon.static_animation)
        can_fire = true
      else:
        rack_bolt()
    elif ADB.get_ammo(weapon.ammo_type).amount <= 0 and weapon.mag <= 0:
      if weapon.empty_clip_scene and GM.player.weapon_sprite.animation != weapon.empty_animation:
        GM.player.weapon_sprite.play(weapon.empty_animation)
        var clip_instance = weapon.empty_clip_scene.instantiate()
        clip_instance.scale.x = GM.player.vega.view_direction
        clip_instance.global_position = GM.player.weapon_sprite.global_position
        clip_instance.rotation_degrees = randf_range(-30, 30)
        clip_instance.angular_velocity = randf_range(-15, 15)
        GlobalFx.add_debris(clip_instance)
      can_fire = false
    
func unjam() -> void:
  GM.player.weapon_sprite.play(weapon.unjam_animation)
  $WeaponTimer.start(weapon.reload_time/2)
  await $WeaponTimer.timeout
  GM.player.weapon_sprite.play(weapon.static_animation)
  if weapon.mag > 0:
    weapon.set_mag(weapon.mag - min(weapon.cartridge_by_shot, weapon.mag))
    eject_shell()
  can_fire = true

func rack_bolt() -> void:
  GM.player.weapon_sprite.play(weapon.unjam_animation)
  $WeaponTimer.start(weapon.reload_time/2)
  await $WeaponTimer.timeout
  GM.player.weapon_sprite.play(weapon.static_animation)
  can_fire = true

func eject_shell() -> void:
  var shell_instance = weapon.casing_scene.instantiate()
  shell_instance.global_position = GM.player.weapon_sprite.global_position
  shell_instance.linear_velocity.x = GM.player.vega.view_direction * randi_range(20, 40)
  shell_instance.linear_velocity.y = randi_range(-75, -150)
  GlobalFx.add_debris(shell_instance)


func toggle_fire_mode() -> void:
  if weapon:
    var modes = weapon.get_fire_modes()
    var index = modes.find(fire_mode)  # Находим индекс текущего режима
    if index != -1:  # Проверяем, что режим существует в списке
      var next_index = wrapi(index + 1, 0, modes.size())  # Циклический переход
      fire_mode = modes[next_index]
    else:
      fire_mode = modes[0]


func start_recoil_timer() -> void:
  $RecoilTimer.start(weapon.recoil_recover_delay)


func _on_recoil_timer_timeout() -> void:
  linear_recoil_counter = 0
  angular_recoil_counter = 0
  GM.player.vega.recoil_angle = 0.0
  GM.player.vega.recoil_position = Vector2.ZERO
