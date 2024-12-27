extends Node2D

var parent: Node
var _header: String
@export var header: String:
  get:
    return _header
  set(value):
    _header = value
    $Header.text = value
var _footer: String
@export var footer: String:
  get:
    return _footer
  set(value):
    _footer = value
    $Footer.text = value
var override_counter: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  if parent:
    position = parent.get_global_transform_with_canvas().origin


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  if parent:
    position = parent.get_global_transform_with_canvas().origin
    var distance = position.distance_to(GM.player.vega.get_global_transform_with_canvas().origin)
    var start_point = to_local(GM.player.vega.get_global_transform_with_canvas().origin)
    var end_point = to_local(position)
    var direction = (end_point - start_point).normalized()
    $Line.points[0] = start_point + direction * 50  # Отступ от начала
    $Line.points[1] = end_point - direction * 20    # Отступ от конца
    if not override_counter:
      footer = "%.1f m" % GM.px_to_m(distance)
