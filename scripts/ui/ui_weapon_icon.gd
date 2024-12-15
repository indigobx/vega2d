extends Control
@export var weapon_short_name: String = "Empty"
#:
  #set(value):
    #$Label.text = value
@export var animation_name: String = "default"
#:
  #set(value):
    #$IconSprite.play(value)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  $Label.text = weapon_short_name
  $IconSprite.play(animation_name)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass
