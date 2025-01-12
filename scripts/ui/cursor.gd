extends AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
  pass


func _on_interact_area_area_entered(area: Area2D) -> void:
  if GM.ui.interaction_mode:
    var actor = area.get_parent()
    if area and actor.has_method("interact"):
      if "hint_text" in actor:
        $TextAbove.visible = true
        $TextAbove.text = actor.hint_text
      if actor.has_method("mouse_over"):
        actor.mouse_over()
      GM.ui.actor = actor
    else:
      $TextAbove.visible = false
      GM.ui.actor = null
  else:
    $TextAbove.visible = false
    GM.ui.actor = null


func _on_interact_area_area_exited(area: Area2D) -> void:
  var actor = area.get_parent()
  if actor.has_method("mouse_out"):
      actor.mouse_out()
  $TextAbove.visible = false
  GM.ui.actor = null
