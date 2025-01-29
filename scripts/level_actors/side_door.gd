extends Node2D

var _is_open: bool = false
@export var is_open: bool:
  get:
    return _is_open
  set(value):
    _is_open = value
    return _is_open

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  %Back.z_index = 0
  %Front.z_index = 25
  close()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
  pass


func _on_is_open_changed(value) -> void:
  if value:
    open()
  else:
    close()


func open() -> void:
  if not is_open:
    %Back.play("back-opening")
    %Front.play("front-moving")
    %Timer.start()
    await %Timer.timeout
    %Back.play("back-open")
    %Front.play("front-open")
    %Blocker.collision_layer = 0
    %Blocker.collision_mask = 0
    is_open = true


func close() -> void:
  if is_open:
    %Back.play("back-closing")
    %Front.play("front-moving")
    %Timer.start()
    await %Timer.timeout
    %Back.play("back-closed")
    %Front.play("front-closed")
    %Blocker.collision_layer = 0b0101
    %Blocker.collision_mask = 0b0101
    is_open = false


func deny():
  %Front.play("front-denied")
  %Timer.start()
  await %Timer.timeout
  %Front.play("front-closed")


func toggle() -> bool:
  if is_open:
    close()
  else:
    open()
  return is_open
