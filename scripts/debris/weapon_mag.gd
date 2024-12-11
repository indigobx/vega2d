extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  rotation_degrees = randf_range(-60, 60)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass


func set_weapon(weapon: String) -> void:
  match weapon:
    "handstarter":
      $MagSprite.play("handstarter")
      $Collision.shape.size = Vector2(6, 12)
      $Collision.position = Vector2(-1, 0)
    "mg":
      $MagSprite.play("mg")
      $Collision.shape.size = Vector2(10, 8)
      $Collision.position = Vector2(1, 0)
