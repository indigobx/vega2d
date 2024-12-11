extends Area2D

@export var size: Vector2i
@export var who_triggers: String = "Vega"
@export var speaker: String = "System"
@export var animation_name: String = "default"
@export_multiline var speech: String = """This is a test."""
@export var steps: int = 10
@export_range(1, 10, 1, "or_greater") var display_time: int = 3
@export var say_on_enter: bool = true
@export var say_on_exit: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  $CollisionShape2D.shape.size = size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  $CollisionShape2D.shape.size = size


func _on_body_entered(body: Node2D) -> void:
  print(body)
  if is_instance_valid(body) and body.name == who_triggers:
    print(body)
    var say = get_tree().root.get_node("Game/Vega/Camera/CanvasLayer/UI/UISay")
    say.who = speaker
    say.what = speech
    say.steps = steps
    say.display_time = display_time
    say.portrait = animation_name
    say.say()
