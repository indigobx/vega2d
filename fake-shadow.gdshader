shader_type canvas_item;

// Цвет тени
uniform vec4 shadow_color = vec4(0.0, 0.0, 0.0, 0.5);

// Размер тени
uniform float shadow_radius : hint_range(0.0, 1.0) = 0.5;

// Смещение тени
uniform vec2 shadow_offset = vec2(0.0, 0.0);

void fragment() {
    // Координаты пикселя с учётом смещения
    vec2 shadow_coords = UV - shadow_offset;

    // Расстояние от центра
    float dist = length(shadow_coords - vec2(0.5));

    // Создание мягкой границы тени
    float alpha = smoothstep(shadow_radius - 0.1, shadow_radius, dist);

    // Цвет пикселя
    COLOR = vec4(shadow_color.rgb, shadow_color.a * (1.0 - alpha));
}
