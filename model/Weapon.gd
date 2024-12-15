extends Node
class_name Weapon

@export_category("General")
@export var display_name: String = "Prototype Weapon"
@export var short_name: String = "PW-001"
@export var weight: float = 1.0
@export var projectile_scene: PackedScene
@export var casing_scene: PackedScene
@export var empty_clip_scene: PackedScene
@export var logic_script: Script
@export var icon_small: Sprite2D
@export var icon_big: Sprite2D

@export_category("Animation")
@export var sprite_frames: SpriteFrames
@export var sprite_offest: Vector2i
@export var static_animation: String = "default"
@export var single_fire_animation: String = "default"
@export var full_auto_animation: String = ""
@export var burst_fire_animation: String = ""
@export var reload_animation: String = "default"
@export var reload_empty_animation: String = ""
@export var overheat_animation: String = ""
@export var recoil_animation: String = ""

@export_category("Damage")
@export var damage: float = 0.0
## damage + randf_range(-damage_random_delta, damage_random_delta)
@export var damage_random_delta: float = 0.0
@export_range(0.0, 100.0, 0.1, "suffix:% per cartridge") var crit_chance: float = 10.0
@export var crit_multiplier: float = 2.0

@export_category("Ammo")
@export var mag_size: int = 1
@export_range(0, 50, 1, "or_greater") var cartridge_by_shot: int = 1
@export_range(0.0, 10.0, 0.1, "or_greater", "suffix:s") var reload_time: float = 1.0
@export var reload_by_cartridge: bool = false
@export var mag_weight: float = 0.5

@export_category("Rate Of Fire")
@export_flags("Single", "Full Auto", "Burst") var fire_modes = 0
@export_custom(PROPERTY_HINT_NONE, "suffix:shots/s") var rate_single: float = 1.0
@export_custom(PROPERTY_HINT_NONE, "suffix:shots/s") var rate_full_auto: float = 2.0
@export_custom(PROPERTY_HINT_NONE, "suffix:shots/s") var rate_burst_fire: float = 5.0
@export_range(1, 10, 1, "or_greater", "suffix:shots") var burst_length: int = 3

@export_category("Recoil")
@export_flags("Angular", "Linear") var recoil_directions = 0
## Positive values raise the barrel
@export_range(-45.0, 45.0, 0.01, "suffix:deg") var angular_recoil = 0.0
## +X moves character backwards, -Y moves down
@export var linear_recoil: Vector2 = Vector2()
@export var shots_before_radial_recoil: int = 2
@export var shots_before_linear_recoil: int = 3
## Time to reset recoil "before" timer
@export_custom(PROPERTY_HINT_NONE, "suffix:s") var recoil_recover_delay: float = 0.0

@export_category("Heat")
@export_range(0.0, 10.0, 0.01, "or_greater") var heat_by_cartridge: float = 1.0
@export var cooling_delay: float = 0.5
@export var cool_per_second: float = 1.0
@export var hot_threshold: float = 50.0
@export var failure_threshold: float = 100.0
@export_flags("Misfire", "Damage User", "Explode", "Force Reload", "Cooking Off") var failure_flags = 0
@export_range(0, 100, 1, "suffix:% per tick") var failure_chance: int = 0

@export_category("Mods")
@export var mods: PackedStringArray
