extends Control

@export var dialog_properties: DialogProperties
var speaking = false
var display_time: int
var steps: int
var auto_hide: bool
var hide_on_action: String
var who: String
var portrait: String
var what: String
var who_color: Color

func _ready() -> void:
  if dialog_properties:
    apply_properties(dialog_properties)
  else:
    print("DialogProperties not assigned.")

func apply_properties(props: DialogProperties) -> void:
  # Применяем свойства из ресурса
  display_time = props.display_time
  steps = props.steps
  auto_hide = props.auto_hide
  hide_on_action = props.hide_on_action
  who = props.who
  who_color = props.who_color
  portrait = props.portrait
  what = props.what

func _process(delta: float) -> void:
  pass

func say():
  $Text.text = what
  $Name.text = who
  $Name.modulate = who_color
  $Portrait.play(portrait)
  visible = true
  var step_value = 1 / float(steps)
  for i in range(0, steps + 1):
    $Text.visible_ratio = i * step_value
    $Timer.start(step_value)
    await $Timer.timeout
  $Timer.one_shot = true
  $Timer.start(display_time)
  await $Timer.timeout
  visible = false
