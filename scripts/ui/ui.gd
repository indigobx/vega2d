extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass


func say(props:DialogProperties) -> void:
  var ui_say = $MarginContainer/Rows/Row1/UISay
  ui_say.apply_properties(props)
  ui_say.say()
