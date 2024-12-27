extends Node2D

@export var call_node: Node
@export var callback: String
@export var callback_parameters: Array
@export_enum("button", "toggle", "key") var behaviour: String
@export var button_on_timer: float
@export var key_item_short_name: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass


func interact() -> void:
  print("aaa")
  if call_node and callback and call_node.has_method(callback):
    print("call")
    call_node.call_deferred("callv", callback, callback_parameters)
