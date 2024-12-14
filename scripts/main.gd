extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  var stats = ""
  stats += "%.1f fps\n" % Performance.get_monitor(Performance.TIME_FPS)
  stats += "%.2f ms time process\n" % Performance.get_monitor(Performance.TIME_PROCESS)
  stats += "%.2f ms physics time\n" % Performance.TIME_PHYSICS_PROCESS
  stats += "%.1f Mb static mem\n" % float(Performance.get_monitor(Performance.MEMORY_STATIC) / 1024 / 1024)
  stats += "%.1f Mb video mem\n" % float(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1024 / 1024)
  stats += "%.1f Mb buffer mem\n" % float(Performance.get_monitor(Performance.RENDER_BUFFER_MEM_USED) / 1024 / 1024)
  stats += "%.1f Mb texture mem\n" % float(Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED) / 1024 / 1024)
  stats += "%.0f objects\n" % Performance.get_monitor(Performance.OBJECT_COUNT)
  stats += "%.0f draw calls\n" % Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
  %UI/System.text = stats
