extends Node2D

var fx_queue = []
var debris_queue = []
var decals_queue = []
@export_range(0, 1000, 1, "or_greater") var max_fx: int = 100
@export_range(0, 100, 1, "or_greater") var max_debris: int = 20
@export_range(0, 100, 1, "or_greater") var max_decals: int = 20


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass


func add_fx(fx, parent=$FX) -> void:
  parent.add_child(fx)
  fx_queue.append(fx)
  if fx_queue.size() > max_fx:
    var oldest = fx_queue.pop_front()
    if oldest and is_instance_valid(oldest):
      oldest.queue_free()


func add_debris(debris, parent=$Debris) -> void:
  parent.add_child(debris)
  debris_queue.append(debris)
  if debris_queue.size() > max_debris:
    var oldest = debris_queue.pop_front()
    if oldest and is_instance_valid(oldest):
      oldest.queue_free()


func add_decal(decal, parent=$Decals) -> void:
  parent.add_child(decal)
  decals_queue.append(decal)
  if decals_queue.size() > max_decals:
    var oldest = decals_queue.pop_front()
    if oldest and is_instance_valid(oldest):
      oldest.queue_free()
