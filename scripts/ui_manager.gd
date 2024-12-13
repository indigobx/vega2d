extends Control

@onready var main_menu = $MainMenu

func _ready() -> void:
  main_menu.get_node("HC1/NewGame").connect("pressed", _on_newgame_pressed)
  main_menu.get_node("HC1/Quit").connect("pressed", _on_quit_pressed)


func _process(delta: float) -> void:
  pass


func _on_newgame_pressed() -> void:
  GameManager.new_game()


func _on_quit_pressed() -> void:
  get_tree().quit()


func toggle_ui(ui:String) -> void:
  match ui.to_lower():
    "ui":
      hide_main_menu()
      show_ui()
    "main_menu", "mainmenu":
      hide_ui()
      show_main_menu()

func show_main_menu() -> void:
  $MainMenu.visible = true

func hide_main_menu() -> void:
  $MainMenu.visible = false

func show_ui() -> void:
  var ui = get_tree().root.find_child("UI", true, false)
  ui.visible = true
  GameManager.reparent_node(ui, "Game/PlayerManager/Vega/PlayerCamera/Camera/CanvasLayer")

func hide_ui() -> void:
  var ui = get_tree().root.find_child("UI", true, false)
  ui.visible = false
