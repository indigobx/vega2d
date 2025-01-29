extends Resource
class_name GlowTexture

@export var albedo_texture: Texture2D
@export var emission_texture: Texture2D
@export var emission_power: float = 5.0

var generated_texture: ImageTexture

#func _init():
  #generate_hdr_texture()

func generate_hdr_texture() -> void:
  if not albedo_texture or not emission_texture:
    push_error("Both albedo and emission textures must be set!")
    return

  var albedo_img = albedo_texture.get_image()
  albedo_img.srgb_to_linear()  # Конвертируем sRGB → Linear
  var emission_img = emission_texture.get_image()

  if albedo_img.get_size() != emission_img.get_size():
    push_error("Albedo and emission textures must have the same size!")
    return

  var size = albedo_img.get_size()
  var hdr_img = Image.create(size.x, size.y, false, Image.FORMAT_RGBAF)

  for y in range(size.y):
    for x in range(size.x):
      var emission_color = emission_img.get_pixel(x, y)
      var albedo_color = albedo_img.get_pixel(x, y)

      if emission_color.is_equal_approx(Color.BLACK):
        hdr_img.set_pixel(x, y, albedo_color)
      else:
        emission_color = Color(emission_color.r, emission_color.g, emission_color.b, 0.0)
        var hdr_color = Color(
          albedo_color.r * (1.0 + emission_power * emission_color.r),
          albedo_color.g * (1.0 + emission_power * emission_color.g),
          albedo_color.b * (1.0 + emission_power * emission_color.b),
          albedo_color.a
        )
        hdr_img.set_pixel(x, y, hdr_color)

  generated_texture = ImageTexture.create_from_image(hdr_img)

# Метод для получения текстуры
func get_texture() -> Texture2D:
  if not generated_texture:
    generate_hdr_texture()
  return generated_texture
