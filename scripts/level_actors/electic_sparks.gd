extends Node2D

@export var cycle_duration: float = 5.0
@export var spark_duration: float = 0.5
@export var damage_min: int = 1
@export var damage_max: int = 10
var timer: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  if timer >= cycle_duration:
    var targets = $Area2D.get_overlapping_areas()
    print(targets)
    for target in targets:
      if target.get_parent().has_method("take_damage"):
        var damage = randi_range(damage_min, damage_max)
        target.get_parent().take_damage(damage, target)
        if target.get_parent().name == "Vega":
          GM.player.energy += damage
        
    timer = 0.0
    $Particles.emitting = true
    $Light.light_once("flicker", spark_duration)
    await get_tree().create_timer(spark_duration*2).timeout
    $Particles.emitting = false
  else:
    timer += delta

      
