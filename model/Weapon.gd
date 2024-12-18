extends Node
class_name Weapon

@export_category("General")
@export var display_name: String = "Prototype Weapon"
@export var short_name: String = "PW-001"
## It's arms animation suffix.
## "near_pistol" or "far_rifle" etc,
## so here should be only "pistol" or "rifle" or "unarmed" or "melee"
@export var size: String = "pistol"
@export var weight: float = 1.0
@export_enum("hitscan", "projectile") var hit_type: String
@export var hitscan_scene: PackedScene
@export var projectile_scene: PackedScene
@export var casing_scene: PackedScene
@export var empty_clip_scene: PackedScene
@export var muzzle_flash_scene: PackedScene
@export var raycast_offset: Vector2i
@export var icon_small: Texture2D
@export var icon_big: Texture2D

@export_category("Animation")
@export var sprite_frames: SpriteFrames
@export var sprite_offest: Vector2i
@export var static_animation: String = "default"
@export var single_fire_animation: String = "default"
@export var full_auto_animation: String = ""
@export var burst_animation: String = ""
@export var reload_animation: String = "default"
@export var empty_animation: String = ""
@export var overheat_animation: String = ""
@export var recoil_animation: String = ""
@export var unjam_animation: String = ""

@export_category("Damage")
@export var damage_mod: float = 0.0
## damage + randf_range(-damage_random_delta, damage_random_delta)
@export var damage_random_delta: float = 0.0
@export_range(0.0, 100.0, 0.1, "suffix:% per cartridge") var crit_chance: float = 10.0
@export var crit_multiplier: float = 2.0
@export var hit_mark_scene: PackedScene

@export_category("Ammo")
@export var mag_size: int = 1
@export var mag: int = 1
@export var ammo_type: String = ""
@export_range(0, 50, 1, "or_greater") var cartridge_by_shot: int = 1
@export_range(0.0, 10.0, 0.1, "or_greater", "suffix:s") var reload_time: float = 1.0
@export var reload_by_cartridge: bool = false
@export var cartridge_weight: float = 0.5
@export var is_chambered: bool = false
@export var can_be_chambered: bool = true

@export_category("Rate Of Fire")
@export_flags("Safe", "Single", "Full Auto", "Burst") var fire_modes = 0
@export_custom(PROPERTY_HINT_NONE, "suffix:shots/s") var rate_single: float = 1.0
@export_custom(PROPERTY_HINT_NONE, "suffix:shots/s") var rate_full_auto: float = 2.0
@export_custom(PROPERTY_HINT_NONE, "suffix:shots/s") var rate_burst: float = 5.0
@export_range(1, 10, 1, "or_greater", "suffix:shots") var burst_length: int = 3

@export_category("Recoil")
@export_flags("Angular", "Linear") var recoil_directions = 0
## Positive values raise the barrel
@export_range(-45.0, 45.0, 0.01, "suffix:deg") var angular_recoil = 0.0
## +X moves character backwards, -Y moves down
@export var linear_recoil: Vector2 = Vector2()
@export var shots_before_angular_recoil: int = 2
@export var shots_before_linear_recoil: int = 3
## Time to reset recoil "before" timer
@export_custom(PROPERTY_HINT_NONE, "suffix:s") var recoil_recover_delay: float = 0.0

@export_category("Spread")
@export_range(0.0, 45.0, 0.01, "suffix:deg") var spread_single: float = 0.5
@export_range(0.0, 45.0, 0.01, "suffix:deg") var spread_full_auto: float = 0.5
@export_range(0.0, 45.0, 0.01, "suffix:deg") var spread_burst: float = 0.5

@export_category("Heat")
@export var heat: float = 0.0
@export_range(0.0, 10.0, 0.01, "or_greater") var heat_by_cartridge: float = 1.0
@export var cooling_delay: float = 0.5
@export var cool_per_second: float = 1.0
@export var hot_threshold: float = 50.0
@export var failure_threshold: float = 100.0
@export_flags("Misfire", "Damage User", "Explode", "Force Reload", "Cooking Off") var failure_flags = 0
@export_range(0, 100, 1, "suffix:% per tick") var failure_chance: int = 0

@export_category("Mods")
@export var mods: PackedStringArray


func set_mag(cs):
  if cs > 0:
    mag = cs
  else:
    mag = 0
  GM.ui.ammobar.update()


func get_fire_modes() -> Array:
  var modes = []
  if (fire_modes & (1 << 0)) != 0:
    modes.append("safe")
  if (fire_modes & (1 << 1)) != 0:
    modes.append("single")
  if (fire_modes & (1 << 2)) != 0:
    modes.append("full_auto")
  if (fire_modes & (1 << 3)) != 0:
    modes.append("burst")
  return modes

func get_recoil_types() -> Array:
  var recoil_types = []
  if (recoil_directions & (1 << 0)) != 0:
    recoil_types.append("angular")
  if (recoil_directions & (1 << 1)) != 0:
    recoil_types.append("linear")
  return recoil_types
