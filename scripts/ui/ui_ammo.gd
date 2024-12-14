extends MarginContainer

@export var ammo:float = 0
@export var ammo_max:float = 100
var frames: int = 0
@export var weapon: String = "default"
@export var state: String = "mag"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  $AmmoSprite.play("default-mag")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  if "%s-mag" % weapon not in $AmmoSprite.sprite_frames.get_animation_names():
    weapon = "default"
  $AmmoSprite.animation = "%s-%s" % [weapon, state]
  $AmmoSprite/Count.text = "%d" % ammo
  if ammo == 0:
    state = "reload"
    $AmmoSprite/Count.modulate = "orange"
  else:
    state = "mag"
    frames = $AmmoSprite.get_frame_count($AmmoSprite.animation)
    var sprite_idx = clamp(
      int(round(float(frames - 1) * (1 - ammo / ammo_max))),
      0,
      frames - 1
    )
    $AmmoSprite.frame = sprite_idx
    $AmmoSprite/Count.modulate = "white"
