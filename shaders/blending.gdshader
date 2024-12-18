shader_type canvas_item;

// Режим смешивания
// 0: Mix, 1: Add, 2: Subtract, 3: Multiply, 4: Screen
uniform int blend_mode_option : hint_range(0, 4) = 0;

// Подключение текстуры экрана
uniform sampler2D screen_texture : hint_screen_texture;

void fragment() {
    vec4 sprite_color = texture(TEXTURE, UV); // Цвет текущего пикселя спрайта
    vec4 screen_color = texture(screen_texture, SCREEN_UV); // Цвет экрана под спрайтом

    vec4 final_color;

    if (blend_mode_option == 0) {
        // Mix (обычное смешивание)
        final_color = sprite_color;
    } else if (blend_mode_option == 1) {
        // Add (аддитивное смешивание)
        final_color = sprite_color + screen_color;
    } else if (blend_mode_option == 2) {
        // Subtract (вычитание)
        final_color = screen_color - sprite_color;
    } else if (blend_mode_option == 3) {
        // Multiply (умножение)
        final_color = sprite_color * screen_color;
    } else if (blend_mode_option == 4) {
        // Screen (инверсное умножение)
        final_color = 1.0 - (1.0 - sprite_color) * (1.0 - screen_color);
    } else {
        // Fallback (если значение за пределами диапазона)
        final_color = sprite_color;
    }

    // Устанавливаем цвет с учетом прозрачности
    final_color.a = sprite_color.a; // Сохраняем альфа-канал спрайта
    COLOR = final_color;
}
