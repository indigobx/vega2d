extends AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass


func _on_interact_area_area_entered(area: Area2D) -> void:
  if area and area.get_parent().has_method("interact"):
    $TextAbove.visible = true
    $TextAbove.text = "Press [b][E][/b] to interact"
    GM.ui.actor = area.get_parent()
  else:
    $TextAbove.visible = false
    GM.ui.actor = null


func _on_interact_area_area_exited(area: Area2D) -> void:
  $TextAbove.visible = false
  GM.ui.actor = null
