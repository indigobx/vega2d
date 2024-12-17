extends Control

var _selected: bool = false

@export var weapon_short_name: String:
  get:
    return weapon_short_name
  set(value):
    $Label.text = value

@export var selected: bool:
  get:
    return _selected
  set(value):
    if selected == value:
      return
    _selected = value
    if value:
      modulate = "white"
      $IconFrame.play("selected")
    else:
      
      modulate = Color("#ffd4a3", 0.75)
      $IconFrame.play("default")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass
