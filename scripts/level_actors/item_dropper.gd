@tool
extends Node

@export var ground_item_manager : NodePath
@export var collide_with_group := &""
@export var loot_table : Resource
@export var one_shot: bool = false
@export var drop_on_enter: bool = false
@export var texture: Texture2D

func _ready():
  connect("body_entered", Callable(self, "_on_body_entered"))
  if loot_table == null:
    loot_table = ItemInstantiator.new()
  if texture:
    $Sprite.texture = texture


func _on_body_entered(body):
  if drop_on_enter:
    if collide_with_group == "" || body.is_in_group(collide_with_group):
      drop_loot()


func drop_loot():
  await loot_table.populate_ground(self, get_node(ground_item_manager))
  if one_shot:
    queue_free()
