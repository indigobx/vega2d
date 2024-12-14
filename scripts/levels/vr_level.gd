extends Node2D

@export var follow_vega: bool = false
var vega: Node = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  vega = get_tree().root.get_node_or_null("Game/PlayerManager/Vega")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  if follow_vega:
    if vega:
      $PointLight2D.global_position = vega.global_position + Vector2(32, -96)
    else:
      vega = get_tree().root.get_node_or_null("Game/PlayerManager/Vega")


func _on_area_2d_body_entered(body: Node2D) -> void:
  if is_instance_valid(body) and body.name == "Vega":
    var props = load("res://data/dialogues/vr_level/right.tres")
    GameManager.ui.say(props)


func _on_area_2d_2_body_entered(body: Node2D) -> void:
  if is_instance_valid(body) and body.name == "Vega":
    var props = load("res://data/dialogues/vr_level/left.tres")
    GameManager.ui.say(props)
