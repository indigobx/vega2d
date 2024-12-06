extends Label

@export var float_duration: float = 1.0  # Время жизни текста
@export var float_distance: float = 50.0  # Расстояние, на которое текст поднимется
@export var start_color: Color = Color(1, 0, 0)  # Начальный цвет текста
@export var end_color: Color = Color(1, 0, 0, 0)  # Конечный цвет (прозрачный)

func _ready():
  # Создаём Tween
  var tween = get_tree().create_tween()

  # Анимация подъёма текста
  tween.tween_property(self, "global_position", global_position - Vector2(0, float_distance), float_duration)

  # Анимация исчезновения текста (изменение цвета)
  tween.tween_property(self, "modulate", end_color, float_duration)

  # Удаляем объект после завершения
  tween.tween_callback(self.queue_free)
