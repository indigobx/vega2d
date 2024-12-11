extends AnimatedSprite2D

@export var max_health: int = 100
@export var health: int = 50

func _ready() -> void:
  max_health = get_parent().max_hp
  health = get_parent().hp

func _process(delta: float) -> void:
  health = get_parent().hp
  var sprite_idx = 10 - clamp(ceil(10.0 * health / max_health), 0, 10)
  $Health.text = "%d" % health
  frame = sprite_idx
