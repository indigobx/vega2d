shader_type canvas_item;

// Радиус размытия
uniform int blur_radius : hint_range(1, 20) = 5;

// Смещение отражения
uniform vec2 reflection_offset = vec2(0.0, 0.1);

// Цветовой фильтр для отражения
uniform vec4 reflection_tint = vec4(0.8, 0.8, 1.0, 0.5);

// Входная текстура (например, ViewportTexture)
uniform sampler2D reflection_texture;

void fragment() {
    vec2 uv = UV + reflection_offset;

    vec4 blurred_color = vec4(0.0);
    int samples = 0;

    // Размываем текстуру по радиусу
    for (int x = -blur_radius; x <= blur_radius; x++) {
        for (int y = -blur_radius; y <= blur_radius; y++) {
            vec2 offset = vec2(float(x), float(y)) / TEXTURE_PIXEL_SIZE;
            blurred_color += texture(reflection_texture, uv + offset);
            samples++;
        }
    }

    blurred_color /= float(samples);

    // Применяем цветовой фильтр
    blurred_color *= reflection_tint;

    COLOR = blurred_color;
}
