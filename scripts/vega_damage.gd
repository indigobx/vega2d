extends Node2D

var damage_text_scene = preload("res://scenes/ui/damage_text.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
  pass



func take_damage(amount, zone) -> void:
  if zone:
    match zone.name:
      "Head":
        amount *= 2.0
      _:
        amount = amount
    var damage_text = damage_text_scene.instantiate()
    damage_text.start_color = Color("crimson", 1.0)
    damage_text.end_color = Color("darkorchid", 0.0)
    damage_text.start_size = 14
    damage_text.end_size = 20
    damage_text.text = "-%d" % amount
    damage_text.global_position = $DamageTextOrigin.global_position
    get_tree().current_scene.add_child(damage_text)
    GM.player.hp -= amount
    var hp_factor = GM.player.hp / GM.player.max_hp
    if hp_factor < 0.9:
      GM.camera.flicker_palette("red48", 0.1)
    
