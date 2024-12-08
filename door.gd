extends Node2D


@export var is_open = false
@export var has_access = "Vega"
@export var auto_open = true
@export var open_signal = false
var is_controllable = false
var scale_closed = Vector2(1.0, 1.0)
var scale_open = Vector2(0.01, 0.01)
var point_closed = Vector2(0, 0)
var point_open = Vector2(-19, -127)
var movement = 0
var open_close_lerp_weight = 0.1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  if is_controllable and !auto_open:
    if Input.is_action_just_pressed("Use"):
      if is_open:
        close()
      else:
        open()
  if movement == 1:
    $Collision/Occluder.scale = lerp($Collision/Occluder.scale, scale_open, open_close_lerp_weight)
    $Collision/Occluder.position = lerp($Collision/Occluder.position, point_open, open_close_lerp_weight)
  if movement == -1:
    $Collision/Occluder.scale = lerp($Collision/Occluder.scale, scale_closed, open_close_lerp_weight)
    $Collision/Occluder.position = lerp($Collision/Occluder.position, point_closed, open_close_lerp_weight)


func open() -> void:
  $Front.play("front-moving")
  $Back.play("back-moving")
  movement = 1
  await $Front.animation_finished
  is_open = true
  $Collision.set_collision_layer_value(1, false)
  $Collision.set_collision_layer_value(2, false)
  $Front.play("front-open")
  $Back.play("back-open")
  movement = 0


func close() -> void:
  is_open = false
  movement = -1
  $Front.play_backwards("front-moving")
  $Back.play_backwards("back-moving")
  $Collision/Occluder.scale = lerp($Collision/Occluder.scale, Vector2(1.0, 1.0), 0.5)
  await $Front.animation_finished
  $Collision.set_collision_layer_value(1, true)
  $Collision.set_collision_layer_value(2, true)
  movement = 0

func _on_control_area_body_entered(body: Node2D) -> void:
  if is_instance_valid(body) and body.name == has_access:
    if auto_open:
      if !is_open:
        open()
    else:
      $Label.visible = true
      $Label.text = "Press E to operate"
      $Label.modulate = "white"
      $Label.global_position = body.global_position + Vector2(0, -80)
      is_controllable = true
    if open_signal:
      $SignalLight.enabled = true
      $SignalLight.color = "limegreen"
      $SignalLight.kind = "constant"
    #await get_tree().create_timer(1).timeout
    #$SignalLight.enabled = false
  if is_instance_valid(body) and body.name != has_access:
    $Label.visible = true
    $Label.text = "Access Denied"
    $Label.modulate = "orange"
    $Label.global_position = body.global_position + Vector2(0, -80)
    is_controllable = false
    $SignalLight.enabled = true
    $SignalLight.color = "orange"
    $SignalLight.kind = "blink"
    await get_tree().create_timer(0.5).timeout
    $SignalLight.enabled = false

func _on_control_area_body_exited(body: Node2D) -> void:
  if is_instance_valid(body):
    if auto_open:
      if is_open:
        close()
    $Label.visible = false
    is_controllable = false
    $SignalLight.enabled = false
