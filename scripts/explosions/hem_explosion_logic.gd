extends Node2D

@export var base_damage:float = 50.0
@export var explosion_radius: float = 250.0
var exploded = false
var explosion_scene = preload("res://scenes/fx/hem_explosion.tscn")
var counter = 1


func _ready() -> void:
  var explosion_instance = explosion_scene.instantiate()
  explosion_instance.global_position = global_position
  GlobalFx.add_fx(explosion_instance)
  $Explosion/CollisionShape2D.shape.radius = explosion_radius


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
  if $Explosion.monitoring:
    var targets = $Explosion.get_overlapping_areas()
    if targets:
      $Explosion.monitoring = false
      for target in targets:
        if target.get_parent().has_method("take_damage"):
          var damage_rate = explosion_radius / global_position.distance_to(target.global_position)
          var damage = base_damage * damage_rate
          target.get_parent().take_damage(damage, target)
  else:
    queue_free()

#var damage_rate = explosion_radius / global_position.distance_to(parent.global_position)
#var damage = base_damage * damage_rate
#parent.take_damage(damage, null)
