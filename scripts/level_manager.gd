extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass


func load_level(name: String) -> void:
  # Убедимся, что текущий уровень (если есть) удалён
  if get_child_count() > 0:
    for child in get_children():
      child.queue_free()
  # Путь к файлу уровня
  var path = "res://scenes/levels/%s.tscn" % name
  # Проверяем, существует ли файл
  #if not FileAccess.file_exists(path):
    #print("Level file does not exist:", path)
    #return
  ## Загружаем уровень
  var level_scene = load(path)
  if level_scene == null:
    print("Failed to load level:", path)
    return
  # Инстанцируем и добавляем в LevelLoader
  var level_instance = level_scene.instantiate()
  add_child(level_instance)

  print("Level loaded successfully:", name)
