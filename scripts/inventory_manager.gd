extends Node

@export var inventory_slots: Array = []
@export var weapon_slots: Dictionary = {
  1: null,
  2: null,
  3: null,
  4: null
}


func _ready() -> void:
  for i in range(25):
    inventory_slots.append(null)
  print("Inventory initialized:", inventory_slots, "\n")
  print("Weapon slots initialized:", weapon_slots, "\n")
