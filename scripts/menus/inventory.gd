extends Control

@export var equipped: Inventory
@export var backpack: Inventory
@export var slots: Dictionary = {
  1: null,
  2: null,
  3: null,
  4: null
}


func _ready() -> void:
  print("Inventory UI Ready")
  update()


func open() -> void:
  GM.ui_manager.toggle_cursor("ui")
  GM.pause()
  visible = true
  update()


func close() -> void:
  update()
  GM.ui_manager.toggle_cursor("combat")
  GM.unpause()
  visible = false


func update() -> void:
  equipped = %EquippedView.inventory
  backpack = %InventoryView.inventory
  for i in range(0, 4):
    var item = %EquippedView.inventory.get_item_at_position(i)
    if item:
      slots[i+1] = WDB.get_weapon(item.extra_properties["wdb"])
    else:
      slots[i+1] = null
      if GM.ui.selected_slot == i+1:
        GM.ui.selected_slot = 0
  GM.ui.update_weapon_icons()
  var vega_weight = GM.player.vega_weight()
  var total_weight = GM.player.weight()
  %VegaWeight.value = vega_weight
  %TotalWeight.value = total_weight
  %VegaWeightLabel.text = "%.1f kg" % vega_weight
  %VegaWeightLabel.position.x = %VegaWeight.size.x / %VegaWeight.max_value * vega_weight - %VegaWeightLabel.size.x - 4
  %InvWeightLabel.text = "%.1f kg" % weight()
  %InvWeightLabel.position.x = %TotalWeight.size.x / %TotalWeight.max_value * vega_weight + %InvWeightLabel.size.x/2 + 4
  %TotalWeightLabel.text = "%.1f kg" % total_weight
  if total_weight > 110.0:
    %TotalWeight.modulate = "red"
    %TotalWeightLabel.modulate = "red"
  else:
    %TotalWeight.modulate = "white"
    %TotalWeightLabel.modulate = "white"


func weight() -> float:
  var inventory_weight = 0.0
  for item in equipped.get_items_ordered():
    inventory_weight += item.extra_properties["weight"] * item.count
  for item in backpack.get_items_ordered():
    inventory_weight += item.extra_properties["weight"] * item.count
  return inventory_weight


func _on_button_pressed() -> void:
  close()


func _on_test_button_pressed() -> void:
  update()


func count_ammo_of_type(mag_type: String) -> int:
  var count = 0
  var all_stacks = backpack.get_items_ordered()
  for stack in all_stacks:
    if "mag_type" in stack.extra_properties:
      if mag_type == stack.extra_properties["mag_type"]:
        count += stack.count
  return count


func _on_sort_pressed() -> void:
  backpack.sort()
