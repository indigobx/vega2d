shader_type canvas_item;

// Параметры размытия
uniform float blur_strength = 1.0;

// Параметры пикселизации
uniform vec2 pixel_size = vec2(8.0, 8.0);

void fragment() {
  // Получаем экранные UV-координаты
  vec2 screen_uv = UV;

  // Пикселизация: округляем координаты UV в зависимости от pixel_size
  vec2 pixel_uv = floor(screen_uv * pixel_size) / pixel_size;

  // Размытие: усредняем соседние пиксели вокруг текущего UV
  vec4 color = vec4(0.0);
  float total_weight = 0.0;

  for (float x = -1.0; x <= 1.0; x++) {
    for (float y = -1.0; y <= 1.0; y++) {
      vec2 offset = vec2(x, y) * blur_strength / vec2(textureSize(VIEWPORT_TEXTURE, 0));
      color += texture(VIEWPORT_TEXTURE, pixel_uv + offset);
      total_weight += 1.0;
    }
  }

  // Усредняем цвета
  color /= total_weight;

  // Устанавливаем итоговый цвет
  COLOR = color;
}
