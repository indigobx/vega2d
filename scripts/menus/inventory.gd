extends Control

var _previous_cursor: String
var slots: Dictionary

func _ready() -> void:
  pass


func _process(delta: float) -> void:
  pass


func open() -> void:
  _previous_cursor = GM.ui_manager.get_current_cursor()
  GM.ui_manager.toggle_cursor("ui")
  GM.pause()
  visible = true


func close() -> void:
  GM.ui_manager.toggle_cursor(_previous_cursor)
  GM.unpause()
  visible = false


func _on_button_pressed() -> void:
  close()


func _on_test_button_pressed() -> void:
  var used_slots = []
  var equipped = %EquippedView.inventory.get_items_ordered()
  for e in equipped:
    var weapon = WDB.get_weapon(e.extra_properties["wdb"])
    var slot = int(e.position_in_inventory.x + 1)
    used_slots.append(slot)
    GM.player.put_to_slot(weapon, slot)
  for i in range(1, 5):
    if i not in used_slots:
      GM.player.clear_slot(i)
