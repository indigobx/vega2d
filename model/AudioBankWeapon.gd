extends Node
class_name AudioBankWeapon

@export var weapon_short_name: String = ""
@export_category("Sound Banks")
@export var single_sounds: Array = [Object]
@export var full_auto_sounds: Array = []
@export var burst_sounds: Array = []
@export var reload_sounds: Array = []
@export var failure_sounds: Array = []
@export_category("Playback")
@export var volume_db: float = 0.0
@export var random_pitch: bool = false
@export var pitch_scale_min: float = 1.0
@export var pitch_scale_max: float = 1.0
@export var attenuation: float = 1.0
@export var max_distance_px: int = 2000

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass
