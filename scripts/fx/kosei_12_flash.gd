extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  $Particles.emitting = true
  $Light.light_once("sine", 0.1)



func _on_particles_finished() -> void:
  queue_free()
