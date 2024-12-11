extends Control

@export var display_time: int = 5
@export var steps: int = 50
@export var auto_hide: bool = false
@export var hide_on_action: String = "Use"
@export var who: String = "Name"
@export var portrait: String = "default"
@export var what: String = "Some text\nSome text"
var speaking = false


func _ready() -> void:
  pass

func _process(delta: float) -> void:
  pass

func say():
  $Text.text = what
  $Name.text = who
  $Portrait.play(portrait)
  visible = true
  var step_value = 1 / float(steps)
  print(steps, "  ", step_value)
  for i in range(0, steps+1):
    $Text.visible_ratio = i * step_value
    $Timer.start(step_value)
    await $Timer.timeout
  $Timer.one_shot = true
  $Timer.start(display_time)
  await $Timer.timeout
  visible = false
