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
var healthbar: Node
var staminabar: Node
var energybar: Node
var heatbar: Node
var ammobar: Node
var firemode: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  for i in range(0, 5):
    weapon_icons[i] = get_node_or_null("%Weapon" + str(i))
  selected_slot = 0
  healthbar = %UIHealthBar
  staminabar = %UIStaminaBar
  energybar = %UIEnergyBar
  heatbar = %UIHeat
  ammobar = %UIAmmo
  firemode = %UIFireMode


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
    GM.player.add_ammo("armsco_25", 30)
    GM.player.add_ammo("hinomaru_4", 8)
  if Input.is_action_just_pressed("Action2"):
    GM.player.vega.pregnancy_stage = max(0, GM.player.vega.pregnancy_stage - 1)
    #GM.player.hp = max(0, GM.player.hp + 10)
  if Input.is_action_just_pressed("Action3"):
    GM.player.vega.pregnancy_stage = min(5, GM.player.vega.pregnancy_stage + 1)
    #GM.player.hp = min(100, GM.player.hp - 10)
  if Input.is_action_just_pressed("Action4"):
    GM.player.hp = 0.0
    GM.player.stamina = 0.0
    GM.player.energy = 0.0
    #say(load("res://data/dialogues/vr_level/what_am_i_doing.tres"))
  
  healthbar.value = GM.player.hp
  healthbar.value_max = GM.player.max_hp
  staminabar.value = GM.player.stamina
  staminabar.value_max = GM.player.max_stamina
  energybar.value = GM.player.energy
  energybar.value_max = GM.player.max_energy


func say(props:DialogProperties) -> void:
  var ui_say = %UISay
  ui_say.apply_properties(props)
  ui_say.say()


func _on_slot_select(slot: int) -> void:
  for k in weapon_icons:
    weapon_icons[k].selected = (k == slot)
