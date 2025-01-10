extends Button

var _content = null
var content:
  get:
    return _content
  set(value):
    _content = value
    update_slot()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  self.pressed.connect(_on_pressed)

# Update slot display based on content
func update_slot() -> void:
  if content != null:
    if "short_name" in content:
      text = content.short_name
    else:
      text = "Unnamed"

    if "icon_small" in content:
      icon = content.icon_small
    else:
      icon = null
  else:
    text = ""
    icon = null

func dump() -> void:
  content = null
  icon = null
  text = ""

# Handle slot press
func _on_pressed() -> void:
  print("Slot pressed with content:", content)
