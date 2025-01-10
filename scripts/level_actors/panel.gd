extends Node2D

@export var call_node: Node
@export var callback: String
@export var callback_parameters: Array
@export_enum("button", "toggle", "key") var behaviour: String
@export var button_on_timer: float
@export var key_item_short_name: String
@export_multiline var hint_text = """Press [b][E][/b] to activate
"""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
  pass


func interact() -> void:
  if call_node and callback and call_node.has_method(callback):
    call_node.call_deferred("callv", callback, callback_parameters)
