extends PointLight2D

@export_enum("constant", "blink", "sine", "flicker") var kind: String = "constant"
@export var blink_on_time: float = 1.0  # Время, когда свет включён
@export var blink_off_time: float = 1.0  # Время, когда свет выключен
@export_range(0.0, 1.0) var flicker_duty_rate: float = 0.5  # Вероятность мерцания
@export var flicker_duty_duration: float = 0.2  # Длительность одного мерцания
var time_passed: float = 0.0
var flicker_active: bool = true  # Статус включённого/выключенного света
@export var max_energy: float = 1.0
@export var min_energy: float = 0.0
var default_kind: String = "constant"  # Режим по умолчанию

func _ready() -> void:
  pass

func _process(delta: float) -> void:
  time_passed += delta
  match kind:
    "constant":
      energy = max_energy  # Постоянный свет
    "blink":
      _blink(delta)  # Код мигания
    "sine":
      _sine_blink(delta)  # Код плавного мерцания
    "flicker":
      _flicker(delta)  # Код случайного мерцания

# Режим мигания
func _blink(delta: float) -> void:
  var total_cycle_time = blink_on_time + blink_off_time
  var cycle_position = fmod(time_passed, total_cycle_time)
  if cycle_position < blink_on_time:
    energy = max_energy  # Включено
  else:
    energy = min_energy  # Выключено

# Режим плавного мерцания (синусоида)
func _sine_blink(delta: float) -> void:
  var sine_value = sin(2 * PI * (time_passed / blink_on_time))
  energy = lerp(min_energy, max_energy, 0.5 * (1 + sine_value))  # Интерполяция между min и max

# Режим случайного мерцания
func _flicker(delta: float) -> void:
  if time_passed >= flicker_duty_duration:
    time_passed = 0.0  # Сброс таймера
    flicker_active = randf() < flicker_duty_rate  # Случайно включаем или выключаем
  energy = max_energy if flicker_active else min_energy

# Функция light
func light_once(with_kind="constant", duration=0.0, on_finish="off") -> void:
  kind = with_kind
  enabled = true
  if duration > 0.0:
    await get_tree().create_timer(duration).timeout
    if on_finish == "off":
      kind = "constant"
      enabled = false
    else:
      kind = on_finish

#func light(kind="constant", duration=1.0, on_finish="off") -> void:
  #self.kind = kind  # Устанавливаем текущий режим света
#
  #if duration > 0:  # Если задана длительность
    #var timer = Timer.new()
    #timer.wait_time = duration
    #timer.one_shot = true
    #timer.connect("timeout", "_on_light_timeout", [on_finish])
    #add_child(timer)  # Добавляем таймер как дочерний узел
    #timer.start()
#
## Сбрасываем режим на завершении
#func _on_light_timeout(on_finish: String) -> void:
  #self.kind = on_finish
