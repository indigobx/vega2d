extends MarginContainer

var _value
@export var value: float:
  get:
    return _value
  set(v):
    _value = v
    _on_value_changed(v)
var _value_max
@export var value_max: float:
  get:
    return _value_max
  set(v):
    _value_max = v
    _on_value_max_changed(v)
var _kind
@export_enum("hp", "stamina", "energy", "other") var kind: String:
  get:
    return _kind
  set(v):
    _kind = v
    _on_kind_changed(v)
@export var round_value: bool = true
var textures = {
  "hp": preload("res://sprites/bars/bigbar/icon-hp.png"),
  "stamina": preload("res://sprites/bars/bigbar/icon-lung.png"),
  "energy": preload("res://sprites/bars/bigbar/icon-energy.png"),
  "other": preload("res://sprites/bars/bigbar/icon-paw.png")
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass


func _on_value_changed(v) -> void:
  $HC/Bar.value = v
  $HC/Current.text = fmt_k(value, round_value)

func _on_value_max_changed(v) -> void:
  $HC/Bar.max_value = v
  $HC/Max.text = fmt_k(value_max, true)

func _on_kind_changed(v) -> void:
  var modulate_color = "gainsboro"
  match kind:
    "hp":
      modulate_color = "#c79ea2"
    "stamina":
      modulate_color = "#c1dac9"
    "energy":
      modulate_color = "#9eacc7"
  $HC/Bar.tint_progress = modulate_color
  $HC/Icon.texture = textures[kind]

func fmt_k(number: float, rounded: bool) -> String:
  # Определяем суффиксы
  var suffixes = ["", "K", "M", "G", "T"]
  var threshold = 10000  # Граница, после которой начинаются сокращения
  # Если число меньше 10000, возвращаем его как есть
  if rounded:
    number = round(number)
  if abs(number) < threshold:
    return "%d" % int(number) if fmod(number, 1) == 0 else "%.1f" % number  # Без дробных, если целое
  # Вычисляем порядок
  var order = floor((log(abs(number)) / log(10)) / 3)
  # Если число больше 999T, возвращаем OVER
  if order >= len(suffixes):
    return "OVER"
  # Считаем сокращённое значение
  var scaled_number = number / pow(1000, order)
  # Округляем в меньшую сторону
  scaled_number = floor(scaled_number)
  # Форматируем результат с суффиксом
  return "%d%s" % [int(scaled_number), suffixes[order]]
