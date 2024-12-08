extends AnimatedSprite2D

@export var ammo:float = 0
@export var ammo_max:float = 100
var frames: int = 0
@export var weapon: String = "default"
@export var state: String = "mag"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  play("default-mag")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  if "%s-mag" % weapon not in sprite_frames.get_animation_names():
    weapon = "default"
  animation = "%s-%s" % [weapon, state]
  $Count.text = "%d" % ammo
  if ammo == 0:
    state = "reload"
    $Count.modulate = "orange"
  else:
    state = "mag"
    frames = sprite_frames.get_frame_count(animation)
    var sprite_idx = clamp(
      int(round(float(frames - 1) * (1 - ammo / ammo_max))),
      0,
      frames - 1
    )
    frame = sprite_idx
    $Count.modulate = "white"
