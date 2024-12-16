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

# Экспортируемое свойство с геттером и сеттером
var selected_weapon: int:
  get:
    return _selected_weapon
  set(value):
    if _selected_weapon != value:  # Проверяем, изменилось ли значение
      _selected_weapon = value
      _on_selected_weapon_changed(value)  # Вызываем функцию при изменении

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
  for i in range(1, 5):
    if is_instance_valid(slots[i]):
      GM.ui.weapon_icons[i].get_node("Icon").texture = slots[i].icon_small

func put_to_slot(item, slot):
  slots[slot] = item

func clear_slots() -> void:
  for i in range(1, 9):
    slots[i] = null

# Функция, вызываемая при изменении selected_weapon
func _on_selected_weapon_changed(value: int) -> void:
  if value == 3:
    weapon_sprite.sprite_frames = slots[3].sprite_frames
    near_arm.play("near_%s" % slots[3].size)
    far_arm.play("far_%s" % slots[3].size)
  else:
    weapon_sprite.sprite_frames = SpriteFrames.new()
    near_arm.play("near_unarmed")
    far_arm.play("far_unarmed")
    print(slots[3])
    if slots[3]:
      print(slots[3].sprite_frames)
