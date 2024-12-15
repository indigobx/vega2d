extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  if Input.is_action_just_pressed("Weapon1"):
    select_slot(1)
  if Input.is_action_just_pressed("Weapon2"):
    select_slot(2)
  if Input.is_action_just_pressed("Weapon3"):
    select_slot(3)
  if Input.is_action_just_pressed("Weapon4"):
    select_slot(4)
  if Input.is_action_just_pressed("Action1"):
    print(GM.player.slots)
  if Input.is_action_just_pressed("Action2"):
    GM.player.put_to_slot(WDB.get_weapon("SmartPistol"), 1)
  if Input.is_action_just_pressed("Action3"):
    GM.player.clear_slots()
  if Input.is_action_just_pressed("Action4"):
    say(load("res://data/dialogues/vr_level/what_am_i_doing.tres"))

func say(props:DialogProperties) -> void:
  var ui_say = $MarginContainer/Rows/Row1/UISay
  ui_say.apply_properties(props)
  ui_say.say()


func set_weapon(slot:int, weapon:String) -> void:
  var icon_node = get_node_or_null("MarginContainer/Rows/Row2/Weapon%s" % slot)
  if icon_node:
    icon_node.get_node("IconSprite").play(weapon)

func select_slot(slot:int) -> void:
  for i in range(1, 5):
    var icon_node = get_node_or_null("MarginContainer/Rows/Row2/Weapon%s" % i)
    if icon_node:
      if i == slot:
        icon_node.modulate = "white"
      else:
        icon_node.modulate = Color(0.7, 0.4, 0.1, 0.5)
