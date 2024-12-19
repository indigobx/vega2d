extends Node

var vega: Node = null
var near_arm: Node
var far_arm: Node
var weapon_sprite: Node
var slots: Dictionary = {
  0: null,
  1: null,
  2: null,
  3: null,
  4: null,
  5: null,
  6: null,
  7: null,
  8: null
}
var _selected_weapon: int = 0  # Приватная переменная для хранения текущего выбранного оружия
var selected_weapon: int:
  get:
    return _selected_weapon
  set(value):
    if _selected_weapon != value:  # Проверяем, изменилось ли значение
      _selected_weapon = value
      _on_selected_weapon_changed(value)  # Вызываем функцию при изменении
var hp: float
var max_hp: float
var hp_restore: float
var energy: float = 200.0
var max_energy: float = 1000.0
var energy_restore: float = 10.0
var stamina: float = 0.0
var max_stamina: float = 500.0
var stamina_restore: float = 2.0
var jump_power: float = 0.85


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  GM.ui.ammobar.update()
  GM.ui.firemode.update()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass

func _physics_process(delta: float) -> void:
  if not stamina == max_stamina:
    var breath_factor = clamp(1.1 - stamina/max_stamina, 0.2, 1.0)
    var ef = Engine.get_physics_frames() * 0.5 * breath_factor
    var breath = clamp(abs(sin(ef))*sin(ef), 0.0, 1.5) * 4
    var restored_stamina = stamina_restore * delta * breath
    stamina = clamp(stamina+restored_stamina, 0.0, max_stamina)
  
  if not hp == max_hp:
    var ef = Engine.get_physics_frames()
    var pulse = max(0.2, sin(ef) * cos(3*ef)) * 2 - 0.2
    var restored_hp = hp_restore * delta * pulse
    hp = clamp(hp+restored_hp, 0.0, max_hp)
  
  if not energy == max_energy:
    var normalized_energy = energy / max_energy
    var energy_rate = max((-4/3) * pow(energy - (1/3), 2), 0.2) * 2
    var restored_energy = energy_restore * delta * energy_rate
    energy = clamp(energy+restored_energy, 0.0, max_energy)
  

func load_instance() -> void:
  vega = load("res://scenes/vega.tscn").instantiate()

func spawn(Vector2 = Vector2.ZERO) -> void:
  add_child(vega)
  vega.global_position = Vector2
  var camera = load("res://scenes/player_camera.tscn").instantiate()
  GM.camera = camera.get_node("Camera")
  vega.add_child(camera)
  weapon_sprite = vega.get_node("ArmsPivot/Arms/Weapon")
  near_arm = vega.get_node("ArmsPivot/Arms/Near")
  far_arm = vega.get_node("ArmsPivot/Arms/Far")
  # should move this to sep function
  put_to_slot(WDB.get_weapon("SmartPistol"), 3)
  put_to_slot(WDB.get_weapon("AR-8"), 4)
  print(ADB)
  add_ammo("armsco_25", 120)
  add_ammo("hinomaru_4", 32)
  print(ADB)
  for i in range(1, 5):
    if is_instance_valid(slots[i]):
      GM.ui.weapon_icons[i].get_node("Icon").texture = slots[i].icon_small
  hp = 100
  max_hp = hp
  hp_restore = 10.0
  GM.ui.healthbar.value_max = max_hp
  GM.ui.healthbar.value = hp

func put_to_slot(item, slot) -> void:
  slots[slot] = item
  GM.ui.weapon_icons[slot].weapon_short_name = item.short_name

func clear_slots() -> void:
  for i in range(1, 9):
    slots[i] = null

func add_ammo(type, amount) -> void:
  var ammo = ADB.get_ammo(type)
  ammo.add_ammo(amount)



func weight() -> float:
  var total_weight = 0.0
  total_weight += vega.weight_base
  total_weight += vega.pregnancy_weight_mod[vega.pregnancy_stage]
  for k in slots:
    if slots[k] and slots[k].weight:
      total_weight += slots[k].weight
  total_weight += ADB.weight_all()
  return total_weight

func v0() -> float:
  var w = weight() - 35
  if w <= 0:
    return -1000.0
  else:
    return -(GM.player.jump_power * sqrt((1.0e7) / w))

func energy_to_jump() -> float:
  var etj = 0.5 * weight() * pow(v0(), 2)
  return etj * 0.00001

func spend_energy(value) -> bool:
  if energy > value:
    energy -= value
    return true
  elif (energy + stamina) > value:
    var from_stamina = value - energy
    energy = 0.0
    stamina -= from_stamina
    return true
  else:
    var dialog_props = DialogProperties.new()
    dialog_props.who = "Operating System v17.4"
    dialog_props.who_color = "red"
    dialog_props.what = """[center]
Not enough [font_size=26][color=blue]energy[/color][/font_size] and [font_size=26][color=green]stamina[/color][/font_size].
Some subsystems [shake][font_size=30][color=red]locked[/color][/font_size][/shake].
You have to [font_size=32]rest[/font_size].[/center]"""
    dialog_props.display_time = 2
    dialog_props.steps = 60
    dialog_props.portrait = "os"
    GM.ui.say(dialog_props)
    return false


# Функция, вызываемая при изменении selected_weapon
func _on_selected_weapon_changed(value: int) -> void:
  if is_instance_valid(slots[value]):
    weapon_sprite.sprite_frames = slots[value].sprite_frames
    near_arm.play("near_%s" % slots[value].size)
    far_arm.play("far_%s" % slots[value].size)
    GM.weapon.weapon = slots[value]
  else:
    weapon_sprite.sprite_frames = SpriteFrames.new()
    near_arm.play("near_unarmed")
    far_arm.play("far_unarmed")
    GM.weapon.weapon = null
