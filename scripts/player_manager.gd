extends Node

var jump_timer: Node = null
var vega: Node = null
var near_arm: Node
var far_arm: Node
var weapon_sprite: Node
var hp: float = 250
var max_hp: float = 250
var hp_restore: float = 10.0
var energy: float = 500.0
var max_energy: float = 1000.0
var energy_restore: float = 20.0
var stamina: float = 0.0
var max_stamina: float = 500.0
var stamina_restore: float = 10.0
var breath: float
var pulse: float
var energy_rate: float
var jump_power: float = 0.85
var hp_level_table = [
  {"threshold": 0.05, "color": Color(1.0, 0.1, 0.1), "palette": "red14", "shake": 6},
  {"threshold": 0.1, "color": Color(1.0, 0.5, 0.5), "palette": "red28", "shake": 4},
  {"threshold": 0.25, "color": Color(1.0, 0.75, 0.75), "palette": "testvega2", "shake": 2},
  {"threshold": 0.5, "color": Color(1.0, 0.5, 0.5)},
  {"threshold": 0.67, "color": Color(1.0, 0.75, 0.75)}
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  print("Player Manager Ready")
  GM.ui.ammobar.update()
  GM.ui.firemode.update()
  jump_timer = $JumpHoldTimer

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
  pass

func _physics_process(delta: float) -> void:
  if not stamina == max_stamina:
    var breath_factor = clamp(1.1 - stamina/max_stamina, 0.2, 1.0)
    var ef = Engine.get_physics_frames() * 0.1 * breath_factor
    breath = clamp(abs(sin(ef))*sin(ef), 0.0, 1.5) * 4
    var restored_stamina = stamina_restore * delta * breath
    stamina = clamp(stamina+restored_stamina, 0.0, max_stamina)
  
  if not hp == max_hp:
    var ef = Engine.get_physics_frames()
    pulse = max(0.2, sin(ef) * cos(3*ef)) * 2 - 0.2
    var restored_hp = hp_restore * delta * pulse
    hp = clamp(hp+restored_hp, 0.0, max_hp)
  
  if not energy == max_energy:
    var normalized_energy = energy / max_energy
    energy_rate = max(1.33 * pow(normalized_energy - 0.2, 2) * 5, 0.2)
    var restored_energy = energy_restore * delta * energy_rate
    energy = clamp(energy+restored_energy, 0.0, max_energy)
  
  hp_effect()
  

func load_instance() -> void:
  vega = load("res://scenes/vega.tscn").instantiate()

func spawn(spawn_point = Vector2.ZERO) -> void:
  GM.audio.play_music("ambient")
  add_child(vega)
  vega.global_position = spawn_point
  var camera = load("res://scenes/player_camera.tscn").instantiate()
  #GM.camera = camera
  vega.add_child(camera)
  weapon_sprite = vega.get_node("ArmsPivot/Arms/Weapon")
  near_arm = vega.get_node("ArmsPivot/Arms/Near")
  far_arm = vega.get_node("ArmsPivot/Arms/Far")
  # should move this to sep function
  #put_to_slot(WDB.get_weapon("RAVEN"), 2)
  #put_to_slot(WDB.get_weapon("SmartPistol"), 3)
  #put_to_slot(WDB.get_weapon("AR-8"), 4)
  #add_ammo("hem_rocket", 4)
  #add_ammo("armsco_25", 120)
  #add_ammo("hinomaru_4", 32)
  GM.ui.healthbar.value_max = max_hp
  GM.ui.healthbar.value = hp



#func add_ammo(type, amount) -> void:
  #var ammo = ADB.get_ammo(type)
  #ammo.add_ammo(amount)

func hp_effect() -> void:
  if hp == max_hp:
    return
  var hp_factor = hp / max_hp
  for entry in hp_level_table:
    if hp_factor < entry["threshold"]:
      GM.ui.modulate = entry["color"]
      if "palette" in entry:
        GM.camera.set_palette(entry["palette"])
        GM.camera.enable_post_shader()
      else:
        GM.camera.disable_post_shader()
      if "shake" in entry:
        vega.camera_shake = Vector2(0, randi_range(-entry["shake"], entry["shake"]))
      return
  GM.ui.modulate = Color("white")


func vega_weight() -> float:
  var current_weight = 0.0
  if vega:
    current_weight += vega.weight_base
    current_weight += vega.pregnancy_weight_mod[vega.pregnancy_stage]
  return current_weight


func weight() -> float:
  var total_weight = 0.0
  total_weight += vega_weight()
  total_weight += GM.inventory.weight()
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

func spend_energy(value, allow_stamina:bool=true) -> bool:
  if energy > value:
    energy -= value
    return true
  elif (energy + stamina) > value and allow_stamina:
    var from_stamina = value - energy
    energy = 0.0
    stamina -= from_stamina
    return true
  else:
    return false
