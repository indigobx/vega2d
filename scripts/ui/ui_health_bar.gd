extends MarginContainer

@export var max_hp: int = 100
@export var hp: int = 50
var frames: int = 0

func _ready() -> void:
  frames = $HealthBarSprite.sprite_frames.get_frame_count("default") - 2

func _process(delta: float) -> void:
  var sprite_idx = frames - clamp(ceil(float(frames) * hp / max_hp), 0, frames) + 1
  if hp <= 0:
    hp = 0
    sprite_idx = frames + 2
  if hp >= max_hp:
    sprite_idx = 0
  $HealthBarSprite/HP.text = "%d" % hp
  $HealthBarSprite/MaxHP.text = "%d" % max_hp
  $HealthBarSprite.frame = sprite_idx
