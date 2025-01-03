extends AnimatedSprite2D

var _label: String
@export var label: String:
  get:
    return _label
  set(value):
    _label = value
    _on_label_set(value)
var _label_visible: bool
@export var label_visible: bool = false:
  get:
    return _label_visible
  set(value):
    _label_visible = value
    _on_label_visible_set(value)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass


func _on_label_set(value) -> void:
  $Label.text = value


func _on_label_visible_set(value) -> void:
  $Label.visible = value
