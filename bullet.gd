extends RigidBody2D


# Called when the node enters the scene tree for the first time.
@export var direction = Vector2()
@export var impulse = 3500
@export var damage = 2
@export var spread = 50

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  if sign(direction.x) < 0:
    $BulletSprite.flip_h = true
    $BulletSprite.offset = Vector2(0, 0)
    impulse = -impulse
  if not is_connected("body_entered",_on_body_entered):
    connect("body_entered", _on_body_entered)
  impulse *= randf_range(0.9, 1.1)
  var v_spread = randf_range(-spread, spread)
  apply_impulse(Vector2(impulse, v_spread).rotated(rotation))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass


func _on_body_entered(body: Node) -> void:
  if body.has_method("take_damage"):  # Проверяем наличие метода take_damage
      body.take_damage(damage)
  var hit_decal = $BulletHit.duplicate()
  hit_decal.visible = true
  hit_decal.position = position
  GlobalFx.add_decal(hit_decal)
  var hit_fx = $HitFx.duplicate()
  hit_fx.visible = true
  hit_fx.position = position
  GlobalFx.add_fx(hit_fx)
  queue_free()
