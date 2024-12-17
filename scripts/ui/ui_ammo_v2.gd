extends MarginContainer

@export var mag_size: int
@export var mag: int
var cartridges = []
var textures = {
  "default": preload("res://sprites/ui/cartridge-default.png"),
  "ar-8": preload("res://sprites/ui/cartridge-ar-8.png"),
  "kosei-12": preload("res://sprites/ui/cartridge-kosei-12.png")
}
var cartridge_chambered: Vector2
var cartridge_1: Vector2
var cartridge_offset_x: String
var cartridge_offset_y: String
var general_offset: Vector2 = Vector2(3, 9)

func update() -> void:
  var weapon = GM.weapon.weapon
  if weapon:
    $Cartridges.visible = true
    $Frame.visible = true
    var ct: Texture2D
    var frame: Vector2
    match weapon.short_name.to_lower():
      "ar-8":
        cartridge_offset_x = "(i % 2) * 5"
        cartridge_offset_y = "i * 3 + 4"
        cartridge_1 = Vector2(3, -1)
        cartridge_chambered = Vector2(3, -8)
        ct = textures["ar-8"]
        frame = Vector2(16, 104)
      "kosei-12":
        cartridge_offset_x = "0"
        cartridge_offset_y = "i * 6 - 2"
        cartridge_1 = Vector2(0, -8)
        cartridge_chambered = Vector2(0, 0)
        ct = textures["kosei-12"]
        frame = Vector2(20, 48)
      _:
        cartridge_offset_x = "0"
        cartridge_offset_y = "i * 6 + 6"
        cartridge_1 = Vector2(0, 0)
        cartridge_chambered = Vector2(5, 0)
        ct = textures["default"]
        frame = Vector2(1, 1)
    mag_size = weapon.mag_size
    mag = weapon.mag
    frame += ceil(general_offset/2)
    $Frame.region_rect = Rect2($Frame.position, frame)
    $Frame.custom_minimum_size = frame
    $Frame/Label.text = "%s/%s" % [mag, mag_size]
    for c in $Cartridges.get_children():
      c.queue_free()
    var mag_counter = mag - 1
    if mag > 0 and weapon.is_chambered and weapon.can_be_chambered:
      var cartridge_instance = TextureRect.new()
      cartridge_instance.texture = ct
      cartridge_instance.position = cartridge_chambered + general_offset
      cartridge_instance.modulate = Color("#ffd4a3", 1.0)
      $Cartridges.add_child(cartridge_instance)
      mag_counter = mag - 2
    if (mag > 0 and not weapon.is_chambered) or (mag > 1 and weapon.is_chambered):
      var cartridge_instance = TextureRect.new()
      cartridge_instance.texture = ct
      cartridge_instance.position = cartridge_1 + general_offset
      $Cartridges.add_child(cartridge_instance)
    for i in range(mag_counter):
      var cartridge_instance = TextureRect.new()
      cartridge_instance.texture = ct
      cartridge_instance.position.x = ee(cartridge_offset_x, {"i": i})
      cartridge_instance.position.y = ee(cartridge_offset_y, {"i": i})
      cartridge_instance.position += general_offset
      $Cartridges.add_child(cartridge_instance)
  else:
    $Cartridges.visible = false
    $Frame.visible = false
    $Frame/Label.text = "no"


func ee(formula: String, vars: Dictionary) -> Variant:
  if formula == "pass" or not vars:
    return vars[vars.keys()[0]]
  var expression = Expression.new()
  var keys = vars.keys()  # Получаем имена переменных
  var values = []  # Создаём массив значений в порядке имён

  for key in keys:
    values.append(vars[key])

  if expression.parse(formula, keys) == OK:
    var result = expression.execute(values)
    if expression.has_execute_failed():  # Проверка на ошибки выполнения
      push_error("Execution failed for formula: %s" % formula)
      return null
    return result
  else:
    push_error("Failed to parse formula: %s" % formula)
    return null
