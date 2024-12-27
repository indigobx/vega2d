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
var lock_marker: Node
var actor: Node

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
  lock_marker = %LockMarker

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
    GM.camera.flicker_palette("1bit", 1.0)
    GM.player.add_ammo("armsco_25", 30)
    GM.player.add_ammo("hinomaru_4", 8)
  if Input.is_action_just_pressed("Action2"):
    GM.player.vega.pregnancy_stage = max(0, GM.player.vega.pregnancy_stage - 1)
    #GM.player.hp = max(0, GM.player.hp + 10)
  if Input.is_action_just_pressed("Action3"):
    GM.player.vega.pregnancy_stage = min(5, GM.player.vega.pregnancy_stage + 1)
    #GM.player.hp = min(100, GM.player.hp - 10)
  if Input.is_action_just_pressed("Action4"):
    var es = GM.level.find_children("Dummy*", "", true, false)
    for e in es:
      e.queue_free()
    var dummy_scene = preload("res://scenes/enemies/dummy.tscn")
    var dummy_instance = dummy_scene.instantiate()
    dummy_instance.global_position = Vector2(-200, 0)
    dummy_instance.name = "Dummy1"
    GM.level.add_child(dummy_instance)
    dummy_instance = dummy_scene.instantiate()
    dummy_instance.global_position = Vector2(500, 20)
    dummy_instance.name = "Dummy2"
    GM.level.add_child(dummy_instance)
    #say(load("res://data/dialogues/vr_level/what_am_i_doing.tres"))
  if Input.is_action_just_pressed("Use"):
    if actor:
      actor.interact()
  
  healthbar.value = GM.player.hp
  healthbar.value_max = GM.player.max_hp
  staminabar.value = GM.player.stamina
  staminabar.value_max = GM.player.max_stamina
  energybar.value = GM.player.energy
  energybar.value_max = GM.player.max_energy

  if GM.player.vega and GM.player.vega.ready:
    var debug_text = """[right]weight [b]%.3f[/b] kg
    weapon weight mod [b]%.3f[/b]
    breath [b]%.3f[/b]
    pulse [b]%.3f[/b]
    energy rate [b]%.3f[/b]
    """ % [
      GM.player.weight(),
      GM.player.vega.weapon_weight_mod,
      GM.player.breath,
      GM.player.pulse,
      GM.player.energy_rate
    ]
    
    
    $Debug/Text.text = debug_text
    $Debug/Breath.add_point(GM.player.breath)
    $Debug/Pulse.add_point(GM.player.pulse)
    $Debug/EnergyRate.add_point(GM.player.energy_rate)


func say(props:DialogProperties) -> void:
  var ui_say = %UISay
  ui_say.apply_properties(props)
  ui_say.say()


func _on_slot_select(slot: int) -> void:
  for k in weapon_icons:
    weapon_icons[k].selected = (k == slot)
