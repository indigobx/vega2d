extends Resource
class_name DialogProperties

@export var display_time: int = 5
@export var steps: int = 50
@export var auto_hide: bool = false
@export var hide_on_action: String = "Use"
@export var who: String = "Name"
@export var who_color: Color = "white"
@export var portrait: String = "default"
@export_multiline var what: String = """This is a test.\nBzzt\nDo you copy?"""
