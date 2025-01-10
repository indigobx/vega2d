extends Control

var _interaction_scene: PackedScene
@export var interaction_scene: PackedScene:
  get:
    return _interaction_scene
  set(value):
    _interaction_scene = value
var _background_color: Color
@export var background_color: Color:
  get:
    return _background_color
  set(value):
    _background_color = value
var _header_label: String
@export var header_label: String = "Header":
  get:
    return _header_label
  set(value):
    _header_label = value


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
  pass


func _on_button_pressed() -> void:
  hide_menu()

func show_menu() -> void:
  GM.pause()
  GM.ui_manager.toggle_cursor("ui")
  $ColorRect.modulate = background_color
  $VBoxContainer/MarginContainer/Label.text = header_label
  if interaction_scene:
    %CenterContainer.add_child(interaction_scene.instantiate())
  visible = true

func hide_menu() -> void:
  print("hide")
  interaction_scene = null
  for child in %CenterContainer.get_children():
    child.queue_free()
  GM.unpause()
  GM.ui_manager.toggle_cursor("combat")
  visible = false
