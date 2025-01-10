extends VBoxContainer

var _header
@export var header: String:
  get:
    return _header
  set(v):
    _header = v
    $Header.text = v
var _color
@export var color: Color:
  get:
    return color
  set(c):
    _color = c
    $TextureProgressBar.tint_under = Color(c * 0.8, 0.5)
    $TextureProgressBar.tint_over = Color(c, 0.5)
    $TextureProgressBar.tint_progress = c
@export var value: float:
  get:
    return _value
  set(v):
    _value = clamp(v, min_value, max_value)  # Ограничиваем значение в пределах min и max
    var normalized_value = (_value - min_value) / (max_value - min_value)  # Нормализуем значение
    $TextureProgressBar.value = int(normalized_value * 360)  # Преобразуем к диапазону 0-360
    $Value.text = format_string % _value  # Обновляем текст

var _min_value = 0.0
@export var min_value: float:
  get:
    return _min_value
  set(v):
    _min_value = v
    _update_progress_bar()

var _max_value = 1.0
@export var max_value: float:
  get:
    return _max_value
  set(v):
    _max_value = v
    _update_progress_bar()

# Приватная переменная для хранения значения
var _value = 0.0

# Формат строки для текста
@export var format_string: String = "%.2f"

# Обновление прогресс-бара при изменении min/max
func _update_progress_bar():
    var normalized_value = (_value - min_value) / (max_value - min_value)  # Нормализуем значение
    $TextureProgressBar.value = int(normalized_value * 360)  # Преобразуем к диапазону 0-360
    $Value.text = format_string % _value  # Обновляем текст


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
  pass
