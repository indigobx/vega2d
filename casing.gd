extends RigidBody2D

@export var direction = Vector2()
var weapon: String = "mg"
var offset_x: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  match weapon:
    "handstarter":
      $CaseSprite.play("handstarter")
      $Collision.shape.size = Vector2(6, 12)
      $Collision.position = Vector2(-1, 0)
    "mg":
      offset_x = -35
      $CaseSprite.play("mg")
      $Collision.shape.size = Vector2(5, 1)
      $Collision.position = Vector2(0, 0.5) 
      apply_impulse(Vector2(25*direction.x, -250))
    "smartgun":
      offset_x = -10
      $CaseSprite.play("mg")
      $Collision.shape.size = Vector2(5, 5)
      $Collision.position = Vector2(0, 0) 
      apply_impulse(Vector2(30*direction.x, -100))
  $CaseSprite.position = Vector2(offset_x*sign(direction.x), 0)
  $Collision.position += $CaseSprite.position
  if sign(direction.x) < 0:
    $CaseSprite.flip_h = true
    $CaseSprite.offset = Vector2(0, 0)
  rotation_degrees += randf_range(-30, 30)

      


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass
