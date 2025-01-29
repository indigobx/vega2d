extends Sprite2D
class_name GlowSprite2D

@export var glow_texture: GlowTexture:
  set(value):
    glow_texture = value
    update_texture()

func _ready():
  update_texture()

func update_texture():
  if glow_texture:
    texture = glow_texture.get_texture()
