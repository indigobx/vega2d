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
var hp: int
var max_hp: int
var ammo: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass

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
  add_ammo("armsco_25", 120)
  for i in range(1, 5):
    if is_instance_valid(slots[i]):
      GM.ui.weapon_icons[i].get_node("Icon").texture = slots[i].icon_small
  hp = 100
  max_hp = hp
  GM.ui.healthbar.max_hp = max_hp
  GM.ui.healthbar.hp = hp

func put_to_slot(item, slot) -> void:
  slots[slot] = item
  GM.ui.weapon_icons[slot].weapon_short_name = item.short_name

func clear_slots() -> void:
  for i in range(1, 9):
    slots[i] = null

func add_ammo(type, amount) -> int:
  if type in ammo:
    ammo[type] += amount
  else:
    ammo[type] = amount
  return ammo[type]

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
