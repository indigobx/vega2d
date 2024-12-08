extends Node2D

var can_tp = false
var accessible = false
@export var allowed_to_tp = "Vega"
@export var bound_up: Node2D
@export var bound_down: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  if bound_up or bound_down:
    if bound_up:
      $Label.text += "[W] to go to %s\n" % bound_up.name
    if bound_down:
      $Label.text += "[S] to go to %s" % bound_down.name
    accessible = true
  else:
    $Label.text = "No access"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  if can_tp and accessible:
    if Input.is_action_just_pressed("Up") and bound_up:
      var vega = get_tree().root.get_node("Game/Vega")
      vega.global_position = bound_up.global_position
    if Input.is_action_just_pressed("Down") and bound_down:
      var vega = get_tree().root.get_node("Game/Vega")
      vega.global_position = bound_down.global_position


func _on_area_2d_body_entered(body: Node2D) -> void:
  if is_instance_valid(body) and body.name == allowed_to_tp:
    can_tp = true
    $Label.visible = true


func _on_area_2d_body_exited(body: Node2D) -> void:
  if is_instance_valid(body) and body.name == allowed_to_tp:
    can_tp = false
    $Label.visible = false
