extends Node

var level: Node = null
var player: Node = null
var ui_manager: Node = null
var ui: Node = null
var camera: Node = null
var weapon: Node = null
var cursor: Vector2
var in_safe_area: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  level = get_tree().root.get_node("Game/LevelManager")
  player = get_tree().root.get_node("Game/PlayerManager")
  ui_manager = get_tree().root.get_node("Game/UIManager")
  ui_manager.toggle_ui("main_menu")
  ui = get_ui()
  weapon = get_tree().root.get_node("Game/WeaponManager")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass


func new_game() -> void:
  ui_manager.hide_main_menu()
  level.load_level("vr_level")
  var spawn_point = level.get_child(0).get_node_or_null("SpawnPoint")
  if spawn_point:
    spawn_point = spawn_point.global_position
  else:
    spawn_point = Vector2.ZERO
  player.load_instance()
  player.spawn(spawn_point)
  ui_manager.toggle_ui("ui")



func reparent_node(node: Node, new_parent: Variant) -> void:
  if node == null:
    print("Error: Node to move is null.")
    return

  # Если new_parent - строка, получаем узел по пути
  if typeof(new_parent) == TYPE_STRING:
    new_parent = get_tree().root.get_node(new_parent)
    if new_parent == null:
      print("Error: New parent node not found for path: ", new_parent)
      return

  # Сохранить глобальную позицию узла (если узел поддерживает позиции)
  var global_pos: Vector2 = Vector2.ZERO
  if node is Node2D:
    global_pos = node.global_position

  # Удалить узел из текущего родителя
  var current_parent = node.get_parent()
  if current_parent != null:
    current_parent.remove_child(node)

  # Добавить узел к новому родителю
  new_parent.add_child(node)

  # Восстановить глобальную позицию (если узел поддерживает позиции)
  if node is Node2D:
    node.global_position = global_pos


func get_ui():
  var ui_group = get_tree().get_nodes_in_group("ui")
  if ui_group:
    return ui_group[0]
  else:
    return get_tree().root.find_child("UI", true, false)
