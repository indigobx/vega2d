extends AnimatedSprite2D

@export var heat:float = 0
@export var heat_min:float = 0
@export var heat_max:float = 100
var frames: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  frames = sprite_frames.get_frame_count("default")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  if heat <= heat_max:
    var sprite_idx = clamp(
      int(round(float(frames - 1) * (heat - heat_min) / (heat_max - heat_min))),
      0,
      frames - 1
    )
    play("default")
    frame = sprite_idx
  if heat > heat_max:
    play("overheat")
