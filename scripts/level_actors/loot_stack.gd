extends RigidBody2D

signal clicked()


## The modulation to apply if filtered out by [member GroundItemManager.view_filter_patterns]. [code]Color(1, 1, 1, 1)[/code] to disable.
@export var filter_hidden_color := Color(0.5, 0.5, 0.5, 0.5)
@export var pickup_radius: int = 10

## [code]true[/code] if hidden by parent's [member GroundItemManager.view_filter_patterns].
var filter_hidden := false:
  set = _set_filter_hidden

var _item_stack: ItemStack
var item_stack: ItemStack:
  get:
    return _item_stack
  set(stack):
    _item_stack = stack
    _set_stack(stack)
@export_multiline var hint_text = """[b][E][/b] to pickup
"""

func _set_filter_hidden(v : bool):
  filter_hidden = v
  modulate = filter_hidden_color if v else Color.WHITE

func _set_stack(stack) -> void:
  stack.display_texture($Visual/Icon)
  var back_color = item_stack.extra_properties.get(&"back_color", Color.GRAY)
  $FX.modulate = back_color
  $Hover/HoverGlow.modulate = back_color
  %Label.text = "%s" % stack.item_type.name
  if stack.count > 1:
    %Label.text += " (×%d)" % stack.count


func _ready() -> void:
  $PickupArea/PickupShape.shape.radius = pickup_radius

func _process(_delta: float) -> void:
  if $Hover.visible and not is_zero_approx(global_rotation):
    $FX.global_rotation = 0.0
    $Hover.global_rotation = 0.0

func interact() -> void:
  var pickup = GM.inventory.backpack.try_add_item(item_stack)
  if pickup:
    queue_free()

func jump_to_pos(pos, _upwards = null):
  global_position = pos
  
func mouse_over() -> void:
  $Hover.visible = true

func mouse_out() -> void:
  $Hover.visible = false
