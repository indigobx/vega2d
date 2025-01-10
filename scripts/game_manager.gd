extends Node


const SCALE_FACTOR: float = 92.0 / 1.7  # Коэффициент преобразования (пиксели на метр)
const METERS_TO_FEET: float = 3.28084  # 1 метр = 3.28084 футов
const INCHES_IN_FOOT: int = 12         # 1 фут = 12 дюймов
var gravity: Vector2
var level: Node = null
var player: Node = null
var ui_manager: Node = null
var ui: Node = null
var inventory_manager: Node = null
var inventory: Node = null
var camera: Node = null
var weapon: Node = null
var cursor: Vector2
var combat_cursor: Node
var interaction_cursor: Node
var ui_cursor: Node
var shader: Node = null
var in_safe_area: bool
#var mouse_cursors = {
  #Input.CURSOR_CROSS: preload("res://sprites/cursors/cross.png"),
  #Input.CURSOR_ARROW: preload("res://sprites/cursors/cursor_arrow.png")
#}



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  print("Game Manager Ready")
  level = get_tree().root.get_node("Game/LevelManager")
  player = get_tree().root.get_node("Game/PlayerManager")
  ui_manager = get_tree().root.get_node("Game/UIManager")
  ui_manager.toggle_ui("main_menu")
  ui = get_ui()
  inventory = get_tree().root.get_node("Game/InventoryManager/Inventory")
  inventory_manager = get_tree().root.get_node("Game/InventoryManager")
  weapon = get_tree().root.get_node("Game/WeaponManager")
  gravity = ProjectSettings.get_setting("physics/2d/default_gravity_vector") \
    * ProjectSettings.get_setting("physics/2d/default_gravity")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
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
  camera = player.vega.get_node("Camera")
  shader = player.vega.get_node("Camera/CanvasLayer/PostShader")
  reparent_node(inventory, ui)
  update_cursors_nodes()


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


func get_ui() -> Variant:
  var ui_group = get_tree().get_nodes_in_group("ui")
  if ui_group:
    return ui_group[0]
  else:
    return get_tree().root.find_child("UI", true, false)


func update_cursors_nodes() -> void:
  combat_cursor = player.vega.get_node_or_null("Cursor")
  #interaction_cursor = ui.get_node_or_null("UICursorSprite")
  ui_cursor = ui.get_node_or_null("UICursor")
  print(combat_cursor, ui_cursor)



func m_to_px(meters: float) -> float:
    """
    Преобразует метры в пиксели.
    """
    return meters * SCALE_FACTOR

func px_to_m(pixels: float) -> float:
    """
    Преобразует пиксели в метры.
    """
    return pixels / SCALE_FACTOR

# Преобразует пиксели в футы (с десятичной частью)
func px_to_feet(pixels: float) -> float:
  var meters = pixels / SCALE_FACTOR  # Перевод пикселей в метры
  return meters * METERS_TO_FEET

# Преобразует пиксели в строку вида "X'Y\""
func px_to_feet_inch(pixels: float) -> String:
  var total_feet = px_to_feet(pixels)
  var feet = int(total_feet)  # Целая часть в футах
  var inches = (total_feet - feet) * INCHES_IN_FOOT  # Остаток в дюймах
  return "%d'%d\"" % [feet, round(inches)]

# Преобразует футы в пиксели
func feet_to_px(feet: float) -> float:
  var meters = feet / METERS_TO_FEET  # Перевод футов в метры
  return meters * SCALE_FACTOR

# Преобразует строку вида "X'Y\"" в пиксели
func feet_inch_to_px(feet_inch: String) -> float:
  # Создаём регулярное выражение
  var regex = RegEx.new()
  regex.compile(r"^(\d+)'(\d+)\"$")  # Регулярное выражение для парсинга строки

  # Ищем совпадения
  var match = regex.search(feet_inch)
  if not match:
    push_error("Invalid format. Use \"X'Y\"\".")
    return 0.0

  # Получаем группы совпадений
  var feet = float(match.get_string(1))  # Группа 1: футы
  var inches = float(match.get_string(2))  # Группа 2: дюймы

  # Конвертируем в пиксели
  var total_feet = feet + (inches / INCHES_IN_FOOT)
  return feet_to_px(total_feet)


func angle_from_up_degrees(angle_deg: float) -> float:
  var new_angle_deg = fmod(270.0 - angle_deg, 360.0)
  if new_angle_deg > 180:
    new_angle_deg -= 360
  return new_angle_deg


func pause() -> void:
  get_tree().paused = true

func unpause() -> void:
  get_tree().paused = false
