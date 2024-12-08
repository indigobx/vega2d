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
    var bodies = $Area2D.get_overlapping_bodies()
    for body in bodies:
      if body.has_method("take_damage"):
        body.take_damage(randi_range(damage_min, damage_max))
    timer = 0.0
    $Particles.emitting = true
    $Light.light_once("flicker", spark_duration)
    await get_tree().create_timer(spark_duration*2).timeout
    $Particles.emitting = false
  else:
    timer += delta

      
