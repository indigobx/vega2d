extends Node

var weapon_bank: AudioBankWeapon
var shot_player: Node
var sounds = {
  "beep": [
    "res://sounds/beep.wav"
  ],
  "double_beep": [
    "res://sounds/double-beep.ogg"
  ],
  "blip": [
    "res://sounds/blip.wav"
  ],
  "buzz": [
    "res://sounds/buzz.wav"
  ],
  "step_basic": [
    "res://sounds/step_01.ogg",
    "res://sounds/step_02.ogg",
    "res://sounds/step_03.ogg"
  ],
  "casing_drop": [
    "res://sounds/casing_drop.ogg"
  ]
}
var music = {
  "main": preload("res://music/main_theme.tres"),
  "threat": preload("res://music/threat.tres"),
  "battle": preload("res://music/battle.tres"),
  "ambient": preload("res://music/ambient.tres")
}

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

func get_random_sound(sound_bank) -> Variant:
  if sound_bank in sounds:
    return load(sounds[sound_bank].pick_random())
  else:
    return null

func get_random_track(sound_bank) -> Variant:
  var bank
  match sound_bank:
    "single":
      bank = weapon_bank.single_sounds
    "full_auto":
      bank = weapon_bank.full_auto_sounds
    "burst":
      bank = weapon_bank.burst_sounds
    "reload":
      bank = weapon_bank.reload_sounds
    "failure":
      bank = weapon_bank.failure_sounds
    "hitscan":
      bank = weapon_bank.hitscan_hit_sounds
    _:
      bank = []
  if bank:
    return bank.pick_random()
  else:
    return null


func play_weapon(sound_bank) -> void:
  var track = get_random_track(sound_bank)
  if weapon_bank.random_pitch:
    shot_player.pitch_scale = randf_range(weapon_bank.pitch_scale_min, weapon_bank.pitch_scale_max)
  else:
    shot_player.pitch_scale = 1.0
  shot_player.max_distance = weapon_bank.max_distance_px
  shot_player.attenuation = weapon_bank.attenuation
  shot_player.volume_db = weapon_bank.volume_db
  shot_player.stream = track
  shot_player.play()



func add_sfx(stream, pos, params=null) -> void:
  var sfx = AudioStreamPlayer2D.new()
  if params:
    if "volume_db" in params:
      sfx.volume_db = params["volume_db"]
    if "pitch_scale" in params:
      sfx.pitch_scale = params["pitch_scale"]
    if "pitch_random" in params:
      sfx.pitch_scale = sfx.pitch_scale + randf_range(-params["pitch_random"], params["pitch_random"])
  sfx.set_stream(stream)
  sfx.global_position = pos
  sfx.autoplay = true
  sfx.finished.connect(sfx.queue_free)
  add_child(sfx)

func play_ui(bank) -> void:
  var track = get_random_sound(bank)
  $UIPlayer.set_stream(track)
  $UIPlayer.play()


func play_music(playlist) -> void:
  if playlist in music:
    $MusicPlayer.stop()
    $MusicPlayer.set_stream(music[playlist])
    $MusicPlayer.play()
