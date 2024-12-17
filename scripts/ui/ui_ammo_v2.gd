extends MarginContainer

@export var mag_size: int
@export var mag: int
@export var is_chambered: bool
var cartridges = []
var ct = load("res://sprites/ui/cartridge-ar-8.png")

func update() -> void:
  var weapon = GM.weapon.weapon
  if weapon:
    mag_size = weapon.mag_size
    mag = weapon.mag
    $Label.text = "%s/%s" % [mag, mag_size]
    for c in $Cartridges.get_children():
      c.queue_free()
    if mag > 0:
      var cartridge_instance = Sprite2D.new()
      cartridge_instance.texture = ct
      cartridge_instance.centered = false
      cartridge_instance.position.y = -1
      cartridge_instance.position.x = 3
      $Cartridges.add_child(cartridge_instance)
    for i in range(mag-1):
      var cartridge_instance = Sprite2D.new()
      cartridge_instance.texture = ct
      cartridge_instance.centered = false
      cartridge_instance.position.y = i * 3 + 4
      cartridge_instance.position.x = (i % 2) * 5
      $Cartridges.add_child(cartridge_instance)
  else:
    $Label.text = "no"
