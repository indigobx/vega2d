extends Node

var weapon_bank: AudioBankWeapon
var shot_player: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass


func get_bank_or_null() -> Variant:
  var banks = $AudioData.get_children(true)
  for b in banks:
    if "weapon_short_name" in b \
    and b.weapon_short_name.to_lower() == GM.weapon.weapon.short_name.to_lower():
      return b
  return null

func update_current_weapon_bank() -> void:
  weapon_bank = get_bank_or_null()

func single_shot() -> void:
  var track = weapon_bank.single_sounds.pick_random()
  if weapon_bank.random_pitch:
    shot_player.pitch_scale = randf_range(weapon_bank.pitch_scale_min, weapon_bank.pitch_scale_max)
  else:
    shot_player.pitch_scale = 1.0
  shot_player.max_distance = weapon_bank.max_distance_px
  shot_player.attenuation = weapon_bank.attenuation
  shot_player.volume_db = weapon_bank.volume_db
  
  shot_player.stream = track
  shot_player.play()

func add_sfx(stream, pos) -> void:
  var sfx = AudioStreamPlayer2D.new()
  sfx.set_stream(stream)
  sfx.global_position = pos
  sfx.autoplay = true
  sfx.finished.connect(sfx.queue_free)
  add_child(sfx)
