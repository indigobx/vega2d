extends Control

var _weapon_short_name: String
@export var weapon_short_name: String:
  get:
    return _weapon_short_name
  set(value):
    _weapon_short_name = value
    $Label.text = value

# Приватная переменная для хранения состояния
var _selected: bool = false

@export var selected: bool:
  get:
    return _selected  # Возвращает реальное состояние
  set(value):
    #if _selected == value:  # Избегаем лишних операций
      #return
    _selected = value  # Сохраняем новое значение
    if value:
      modulate = "white"
      $IconFrame.play("selected")
    else:
      modulate = Color("#ffd4a3", 0.75)
      $IconFrame.play("default")



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  selected = _selected

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass
