extends Node

var _weapon: Weapon
@export var weapon: Weapon:
  get:
    return _weapon
  set(value):
    _on_weapon_change(value)

func _on_weapon_change(value) -> void:
  _weapon = value
  GM.ui.ammobar.update()

var can_fire: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass



func fire():
  if weapon and can_fire:
    weapon.set_mag(weapon.mag - min(weapon.cartridge_by_shot, weapon.mag))
    if weapon.hit_type == "hitscan":
      hitscan()
    if weapon.mag <= 0:
      GM.weapon.can_fire = false
      weapon.set_mag(0)
      GM.ui.say(load("res://data/dialogues/vr_level/ammos_out.tres"))
  else:
    if weapon.mag == 0:
      reload()
    else:
      unjam()


func hitscan():
  var ray = GM.player.vega.ray
  var arms_pivot = GM.player.vega.arms_pivot
  var hitscan_instance = weapon.hitscan_scene.instantiate()
  var hit_mark = weapon.hit_mark_scene.instantiate()
  var p0 = ray.global_position
  var p1 = p0 + Vector2(1024, 0).rotated(arms_pivot.global_rotation)
  ray.force_raycast_update()
  if ray.is_colliding():
    var target = ray.get_collider()
    p1 = ray.get_collision_point()
  hitscan_instance.hit_point = p1
  hitscan_instance.points[0] = p0
  hitscan_instance.points[1] = p1
  GlobalFx.add_fx(hitscan_instance)
  hit_mark.global_position = p1
  GlobalFx.add_decal(hit_mark)
  

func reload():
  if weapon and weapon.ammo_type in GM.player.ammo:
    GM.player.weapon_sprite.play(weapon.reload_animation)
    await get_tree().create_timer(weapon.reload_time).timeout
    var ammo_to_reload = min(weapon.mag_size, GM.player.ammo[weapon.ammo_type])
    weapon.set_mag(ammo_to_reload)
    GM.player.ammo[weapon.ammo_type] -= ammo_to_reload
    can_fire = true
    GM.player.weapon_sprite.play(weapon.static_animation)
    
func unjam():
  GM.player.weapon_sprite.play(weapon.unjam_animation)
  await get_tree().create_timer(0.7).timeout
  GM.player.weapon_sprite.play(weapon.static_animation)
  can_fire = true
