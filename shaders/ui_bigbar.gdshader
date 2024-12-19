shader_type canvas_item;

// Скорость движения разряда
uniform float speed : hint_range(0.1, 10.0) = 2.0;
// Частота генерации разряда
uniform float frequency : hint_range(1.0, 10.0) = 5.0;
// Толщина линии
uniform float thickness : hint_range(1.0, 5.0) = 2.0;
// Цвет молнии
uniform vec4 lightning_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
  vec2 uv = FRAGCOORD.xy / TEXTURE_PIXEL_SIZE;

  // Анимация разряда (движение слева направо)
  float time_offset = mod(TIME * speed, 1.0);

  // Генерация "неровностей" разряда
  float noise = sin((uv.y + time_offset) * frequency) * 0.5 + 0.5;

  // Позиция молнии по X
  float lightning_x = uv.x - time_offset;

  // Расстояние до линии разряда
  float dist_to_line = abs(noise - lightning_x);

  // Проверка, попадает ли пиксель в зону разряда
  if (dist_to_line < thickness * TEXTURE_PIXEL_SIZE.x) {
    COLOR = lightning_color;
  } else {
    discard; // Прозрачный фон вне линии разряда
  }
}
