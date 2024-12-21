@tool
extends Node

@export_dir var input_folder
@export var output_filename: String = "generated"
@export_dir var output_path
@export var frame_size: Vector2i = Vector2i(128, 128)  # Размер одного кадра
@export var fps_dict: Dictionary = {  # FPS для каждого действия
  "walk": 12,
  "walk-forward": 12,
  "walk_forward": 12,
  "jump": 12,
  "walk-backward": 6,
  "walk_backward": 6
}
@export var exclude_patterns: Array = []  # Список исключений
@export var create_animations: bool = false:
  get:
    return create_animations
  set(value):
    if value:  # Если галочка установлена
      create_animations = false
      _create_animations()

func _create_animations() -> void:
  var sprite_frames = SpriteFrames.new()
  var files = _get_files_recursive(input_folder)

  for file_path in files:
    var file_name = file_path.get_file()
    if file_name.ends_with(".png") and not _is_excluded(file_name):
      # Разбор имени файла
      #var parts = file_name.rsplit("_", 4)
      #if parts.size() < 4:
        #print("Skipping invalid file name:", file_name)
        #continue
      #var action = parts[0]
      #var variation = parts[1] if parts[1].is_valid_int() else null
      #var stage = parts[2]
      #var kind = parts[3].replace(".png", "")
      var rx = RegEx.new()
      rx.compile("([a-zA-Z_]+)([0-9]*)_([0-9]+)_([a-zA-Z]+).png")
      var result = rx.search(file_name)
      if not result:
        print("Skipping invalid file name:", file_name)
        continue
      var action = result.get_string(1)
      var variation = result.get_string(2)
      var stage = result.get_string(3)
      var kind = result.get_string(4).replace(".png", "")
      print("       %s %s %s %s" % [action, variation, stage, kind])
      # Устанавливаем FPS из словаря
      var fps = fps_dict.get(action, 12)  # 12 FPS по умолчанию

      # Добавляем анимацию
      var animation_name = "%s%s_%s_%s" % [action, "_" + variation if variation else "", stage, kind]
      sprite_frames.add_animation(animation_name)

      # Загружаем спрайтшит
      var texture = load(file_path)
      var cols = int(texture.get_width() / frame_size.x)
      var rows = int(texture.get_height() / frame_size.y)
      var frame_count = cols * rows
      print("Processing file:", file_name)
      print("%s cols %s rows %s frames" % [cols, rows, frame_count])

      for i in range(frame_count):
        var x = int(i % cols) * frame_size.x
        var y = int(i / cols) * frame_size.y
        var rect = Rect2(Vector2(x, y), frame_size)

        # Проверяем, если кадр полностью прозрачен
        var sub_texture = get_subtexture(texture, rect)
        if _is_fully_transparent(sub_texture):
          print("Skipping fully transparent frame at index:", i)
          continue

        sprite_frames.add_frame(animation_name, sub_texture)

      sprite_frames.set_animation_speed(animation_name, fps)
      print("Added animation:", animation_name, "with FPS:", fps)

  # Сохраняем SpriteFrames в файл
  var output = output_path + "/" + output_filename + ".tres"
  var save_result = ResourceSaver.save(sprite_frames, output)
  if save_result == OK:
    print("Animations saved to:", output, "\n", save_result)
  else:
    print("Error saving animations:", save_result)

func get_subtexture(sheet: Texture2D, region: Rect2) -> AtlasTexture:
  var atlas_texture = AtlasTexture.new()
  atlas_texture.atlas = sheet
  atlas_texture.region = region  # Определяем регион для вырезки
  return atlas_texture

func _is_fully_transparent(texture: AtlasTexture) -> bool:
  # Получаем данные изображения через get_image()
  var image = texture.atlas.get_image()
  if image.is_empty():
    print("Error: Unable to get image from texture")
    return true

  # Проходим по региону текстуры
  for y in range(int(texture.region.position.y), int(texture.region.position.y + texture.region.size.y)):
    for x in range(int(texture.region.position.x), int(texture.region.position.x + texture.region.size.x)):
      var color = image.get_pixel(x, y)
      if color.a > 0.01:  # Если хоть один пиксель не прозрачен
        return false

  return true



func _get_files_recursive(dir_path: String) -> Array:
  var result = []
  var dir = DirAccess.open(dir_path)
  if not dir:
    print("Error: Could not open directory:", dir_path)
    return result

  dir.list_dir_begin()
  var file_name = dir.get_next()
  while file_name != "":
    if dir.current_is_dir() and file_name != "." and file_name != "..":
      result += _get_files_recursive(dir_path + "/" + file_name)  # Рекурсивный вызов
    elif file_name.ends_with(".png"):  # Только PNG-файлы
      result.append(dir_path + "/" + file_name)
    file_name = dir.get_next()

  dir.list_dir_end()
  return result

func _is_excluded(file_name: String) -> bool:
  for pattern in exclude_patterns:
    if file_name.match(pattern):  # Проверка соответствия шаблону
      print("Excluded:", file_name, "by pattern:", pattern)
      return true
  return false
