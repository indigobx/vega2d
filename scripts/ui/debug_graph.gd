extends Panel

# Пример данных для графика
@export var data_points: Array
@export var min_value: float = 0.0
@export var max_value: float = 1.0
@export var graph_color: Color = "red"
@export var is_dynamic: bool = true
@export var autoscale_min: bool = false
@export var autoscale_max: bool = true
@export var show_values: bool = true

func _ready():
  _draw()
  if show_values and data_points.min() and data_points.max():
    $Values.text = "min %.3f\nmax %.3f" % [data_points.min(), data_points.max()]

func _process(_delta: float) -> void:
  if is_dynamic:
    queue_redraw()
    if show_values and data_points.min() and data_points.max():
      $Values.text = "min %.3f\nmax %.3f" % [data_points.min(), data_points.max()]

func add_point(y) -> void:
  if data_points.size() >= size.x - 2:
    data_points.pop_front()
  data_points.append(y)
  if autoscale_max:
    max_value = data_points.max()
  if autoscale_min:
    min_value = data_points.min()

func _draw():
  if data_points.size() < 2:
    return
  var scale_y = (size.y-2) / max_value
  for i in range(data_points.size() - 1):
    var p0 = Vector2(i+1, size.y - 1 - data_points[i] * scale_y)
    var p1 = Vector2(i+2, size.y - 1 - data_points[i+1] * scale_y)
    draw_line(p0, p1, graph_color)
