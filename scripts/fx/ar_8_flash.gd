extends Node2D


func _ready() -> void:
  $Particles.emitting = true
  $Light.light_once("constant", 0.05)

func _on_particles_finished() -> void:
  queue_free()
