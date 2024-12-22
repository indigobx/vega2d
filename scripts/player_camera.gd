extends Node2D

var palettes = {
  "retrotronic": preload("res://palettes/dither/retrotronic.png"),
  "1bit": preload("res://palettes/dither/1bit-monitor-glow.png"),
  "cga_high": preload("res://palettes/dither/cga-palette-0-high.png"),
  "testvega2": preload("res://palettes/dither/testvega2.png"),
  "red14": preload("res://palettes/dither/red-1-4.png"),
  "red28": preload("res://palettes/dither/red-2-8.png"),
  "red48": preload("res://palettes/dither/red-4-8.png")
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass


func set_palette(palette: Variant) -> void:
  if is_instance_of(palette, TYPE_STRING):
    palette = palettes[palette]
  %PostShader.material.set_shader_parameter("dither_palette", palette)

func enable_post_shader() -> void:
  %PostShader.visible = true

func disable_post_shader() -> void:
  %PostShader.visible = false

func flicker_palette(palette_name: String, time: float) -> void:
  var previous_palette = %PostShader.material.get_shader_parameter("dither_palette")
  var was_shader_enabled = %PostShader.visible
  set_palette(palette_name)
  if not was_shader_enabled:
    enable_post_shader()
  await get_tree().create_timer(time).timeout
  if not was_shader_enabled:
    disable_post_shader()
  set_palette(previous_palette)
  
