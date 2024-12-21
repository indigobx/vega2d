extends Label

@export var float_duration: float = 1.0  # Время жизни текста
@export var float_distance_min: float = 50.0
@export var float_distance_max: float = 100.0  # Расстояние, на которое текст поднимется
@export var float_side_min: float = -50.0
@export var float_side_max: float = 50.0
@export var start_color: Color = Color(1, 0, 0)  # Начальный цвет текста
@export var end_color: Color = Color(1, 0, 0, 0)  # Конечный цвет (прозрачный)


func _ready():
  # Создаём Tween
  var tween = get_tree().create_tween()

  # Анимация подъёма текста
  var float_distance = randf_range(float_distance_min, float_distance_max)
  var float_side = randf_range(float_side_min, float_side_max)
  tween.tween_property(self, "global_position", global_position - Vector2(float_side, float_distance), float_duration)
  # Анимация исчезновения текста (изменение цвета)
  tween.tween_property(self, "modulate", end_color, float_duration)

  # Удаляем объект после завершения
  tween.tween_callback(self.queue_free)
