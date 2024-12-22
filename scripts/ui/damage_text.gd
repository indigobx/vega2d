extends Label

@export var float_duration: float = 1.0  # Время жизни текста
@export var float_distance_min: float = 50.0
@export var float_distance_max: float = 100.0  # Расстояние, на которое текст поднимется
@export var float_side_min: float = -50.0
@export var float_side_max: float = 50.0
@export var start_color: Color = Color("darkred", 1.0)  # Начальный цвет текста
@export var end_color: Color = Color("red", 0.0)  # Конечный цвет (прозрачный)
@export var start_size: int = 16
@export var end_size: int = 32

func _ready():
  label_settings = label_settings.duplicate()
  label_settings.font_size = start_size
  label_settings.font_color = start_color
  # Создаём Tween
  var tween = get_tree().create_tween().set_parallel(true)
  # Анимация подъёма текста
  var float_distance = randf_range(float_distance_min, float_distance_max)
  var float_side = randf_range(float_side_min, float_side_max)
  tween.tween_property(self, "global_position", global_position - Vector2(float_side, float_distance), float_duration)
  # Анимация исчезновения текста (изменение цвета)
  tween.tween_property(label_settings, "font_color", end_color, float_duration)
  tween.tween_property(label_settings, "font_size", end_size, float_duration)

  # Удаляем объект после завершения
  tween.chain().tween_callback(self.queue_free)
