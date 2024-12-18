shader_type canvas_item;

// Цвет свечения (когда туман освещён)
uniform vec4 glow_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

// Интенсивность свечения
uniform float glow_intensity : hint_range(0.0, 5.0) = 2.0;

// Коэффициент затухания в тени
uniform float shadow_dimming : hint_range(0.0, 1.0) = 0.3;

// Текстура света
uniform sampler2D light_texture : hint_screen_texture;

void fragment() {
    // Получаем базовый цвет из текстуры спрайта
    vec4 base_color = texture(TEXTURE, UV);

    // Получаем значение освещения из текстуры света
    float light_factor = texture(light_texture, SCREEN_UV).r; // Берём яркость света (красный канал)

    // Рассчитываем итоговый цвет
    vec4 lit_color = base_color * glow_color * light_factor * glow_intensity; // Освещённые пиксели
    vec4 shadow_color = base_color * shadow_dimming;                          // Пиксели в тени

    // Смешиваем освещённые и затенённые цвета
    vec4 final_color = mix(shadow_color, lit_color, light_factor);

    // Устанавливаем итоговый цвет пикселя
    COLOR = final_color;
}
