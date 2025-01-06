extends Control

var slot_scene = load("res://scenes/menus/inventory_slot.tscn")


func _ready() -> void:
  for i in range(25):
    var slot_instance = slot_scene.instantiate()
    %InventorySlots.add_child(slot_instance)


func _process(delta: float) -> void:
  pass
