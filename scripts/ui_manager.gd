extends Control

@onready var main_menu = $MainMenu


func _ready() -> void:
  print("UI Manager Ready")
  main_menu.get_node("HC1/NewGame").connect("pressed", _on_newgame_pressed)
  main_menu.get_node("HC1/Quit").connect("pressed", _on_quit_pressed)
  $UI.add_to_group("ui")


func _process(delta: float) -> void:
  pass


func _on_newgame_pressed() -> void:
  GM.new_game()


func _on_quit_pressed() -> void:
  get_tree().quit()


func get_ui():
  var ui_group = get_tree().get_nodes_in_group("ui")
  if ui_group:
    return ui_group[0]
  else:
    return get_tree().root.find_child("UI", true, false)


func toggle_ui(ui:String) -> void:
  match ui.to_lower():
    "ui":
      hide_main_menu()
      show_ui()
    "main_menu", "mainmenu":
      hide_ui()
      show_main_menu()
  GM.ui = get_ui()

func show_main_menu() -> void:
  $MainMenu.visible = true

func hide_main_menu() -> void:
  $MainMenu.visible = false

func show_ui() -> void:
  #var ui = get_tree().root.find_child("UI", true, false)
  print(get_tree().get_nodes_in_group("ui"))
  var ui = get_ui()
  ui.visible = true
  GM.reparent_node(ui, "Game/PlayerManager/Vega/Camera/CanvasLayer")

func hide_ui() -> void:
  #var ui = get_tree().root.find_child("UI", true, false)
  var ui = get_ui()
  ui.visible = false

func say(props:DialogProperties) -> void:
  var ui = get_ui()
  ui.say(props)

func toggle_cursor(cursor) -> void:
  match cursor:
    "combat", 0:
      GM.combat_cursor.visible = true
      GM.ui_cursor.visible = false
      #GM.interaction_cursor.visible = false
    "ui", 1:
      GM.combat_cursor.visible = false
      GM.ui_cursor.visible = true
      GM.ui_cursor.label_visible = false
      #GM.interaction_cursor.visible = false
    "interaction", 2:
      GM.combat_cursor.visible = false
      GM.ui_cursor.visible = false
      #GM.interaction_cursor.visible = true
    _:
      GM.combat_cursor.visible = false
      GM.ui_cursor.visible = true
      GM.ui_cursor.play("warn")
      GM.ui_cursor.label = "Toggled to invalid cursor\nin UI Manager"
      GM.ui_cursor.label_visible = true
      #GM.interaction_cursor.visible = false

func get_current_cursor() -> String:
  if GM.ui_cursor.visible:
    return "ui"
  if GM.combat_cursor.visible:
    return "combat"
  return "other"
