extends Control


var weapon_icons: Dictionary = {}
var selected_slot: int:
  get:
    return GM.player.selected_weapon
  set(value):
    # Если выбран тот же самый слот, переключаем на слот 0
    if value == GM.player.selected_weapon:
      value = 0
    if GM.player.selected_weapon != value:  # Избегаем лишней работы, если слот не меняется
      GM.player.selected_weapon = value
      _on_slot_select(value)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  for i in range(0, 5):
    weapon_icons[i] = get_node_or_null("MarginContainer/Rows/Row2/Weapon%s" % i)
  selected_slot = 0
  #weapon_icons[3].get_node("Sprite").texture = GM.player.slots[3].icon_small


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  if Input.is_action_just_pressed("Weapon1"):
    selected_slot = 1
  if Input.is_action_just_pressed("Weapon2"):
    selected_slot = 2
  if Input.is_action_just_pressed("Weapon3"):
    selected_slot = 3
  if Input.is_action_just_pressed("Weapon4"):
    selected_slot = 4
  if Input.is_action_just_pressed("Action1"):
    print(GM.player.slots)
    print(GM.player.selected_weapon)
  if Input.is_action_just_pressed("Action2"):
    GM.player.put_to_slot(WDB.get_weapon("SmartPistol"), 3)
  if Input.is_action_just_pressed("Action3"):
    GM.player.clear_slots()
  if Input.is_action_just_pressed("Action4"):
    say(load("res://data/dialogues/vr_level/what_am_i_doing.tres"))


func say(props:DialogProperties) -> void:
  var ui_say = $MarginContainer/Rows/Row1/UISay
  ui_say.apply_properties(props)
  ui_say.say()


func _on_slot_select(slot: int) -> void:
  for k in weapon_icons:
    weapon_icons[k].selected = (k == slot)
