extends Node2D

@export var follow_vega: bool = false
var vega: Node = null
@export var safe_by_default: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  vega = get_tree().root.get_node_or_null("Game/PlayerManager/Vega")
  GM.in_safe_area = safe_by_default


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
  if follow_vega:
    if vega:
      $PointLight2D.global_position = vega.global_position + Vector2(32, -96)
    else:
      vega = get_tree().root.get_node_or_null("Game/PlayerManager/Vega")
  
  $Area2D/Polygon2D.texture.noise.offset.y = sin(Engine.get_frames_drawn() / 10) * 30

func _on_area_2d_body_entered(body: Node2D) -> void:
  if body and body.name == "Vega":
    body.env_speed_mod = 0.33

func _on_area_2d_body_exited(body: Node2D) -> void:
  if body and body.name == "Vega":
    body.env_speed_mod = 1.0


func drop_ammo() -> void:
  $Loot/AmmoDropper.drop_loot()
  $Lights/PointLight2D.color = "limegreen"
  $Lights/PointLight2D.light_once("constant", 0.15)

func drop_weapon() -> void:
  if get_node_or_null("Loot/WeaponDropper"):
    $Loot/WeaponDropper.drop_loot()
    $Lights/PointLight2D.color = "limegreen"
    $Lights/PointLight2D.light_once("constant", 0.15)
  else:
    $Lights/PointLight2D.color = "orange"
    $Lights/PointLight2D.light_once("sine", 0.5)


func open_panel_menu() -> void:
  var panel_menu_scene = load("res://scenes/menus/door_panel.tscn")
  GM.ui.interaction.interaction_scene = panel_menu_scene
  GM.ui.interaction.background_color = Color("black", 0.5)
  GM.ui.interaction.header_label = "Door Panel"
  GM.ui.interaction.show_menu()
