extends Node
class_name Ammo

@export_category("General")
@export var display_name: String
@export var short_name: String
@export var type_name: String
@export var caliber: String
@export_range(0.0, 5.0, 0.001, "or_greater") var cartridge_weight: float
@export_category("Damage")
@export var damage_base: String
@export_category("Visual")
@export var icon_ui: Sprite2D
@export var icon_small: Sprite2D
@export var icon_big: Sprite2D
@export var item_scene: PackedScene
