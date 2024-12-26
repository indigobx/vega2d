extends Node2D

@export_category("Projectile")
@export var projectile_mass: float = 1.0
@export var projectile_gravity_scale: float = 1.0
@export var initial_rotation_deg: float = 0.0
@export var initial_velocity: Vector2 = Vector2.ZERO
@export var initital_impulse: Vector2 = Vector2.ZERO
@export var initial_torque: float = 0.0
@export var impulse_per_physics_frame: Vector2 = Vector2.ZERO
@export var torque_per_physics_frame: float = 0.0
@export var velocity_limit: float = 200.0
@export_category("Weapon")
@export var initial_spread_deg: float = 0.0
@export_category("Calculation")
@export var max_calculation_frames: int = 100
@export var stop_on_zero_approx: bool = true
@export_category("Display")
@export var color: Color = Color("red", 1.0)
var mf = 12.0
var physics_fps = 60

func update() -> void:
  calculate_trajectory($Trajectory)
  $Trajectory.modulate = color
  $Trajectory.queue_redraw()

func calculate_trajectory(line: Line2D) -> void:
  # Очищаем предыдущую траекторию
  line.clear_points()

  # Инициализация начальных параметров
  var position = Vector2.ZERO
  var rotation = deg_to_rad(initial_rotation_deg)
  var velocity = initial_velocity + initital_impulse.rotated(rotation) / projectile_mass
  var gravity = Vector2(0, 98) * projectile_gravity_scale
  var active_flight_time = 0.5  # Задаем время, когда активны импульсы (аналог таймера $Timer)

  var time_step = 1.0 / physics_fps

  # Симуляция траектории
  for frame in range(max_calculation_frames):
    # Добавляем точку в Line2D
    line.add_point(position)

    # Прекращаем расчёт, если скорость близка к нулю и включён флаг остановки
    if stop_on_zero_approx and velocity.is_zero_approx():
      break

    # Применяем гравитацию
    velocity += gravity * time_step

    # Применяем импульс только в течение активного времени
    if frame * time_step <= active_flight_time:
      velocity += impulse_per_physics_frame / projectile_mass * time_step

    # Ограничиваем скорость
    velocity = velocity.limit_length(velocity_limit)

    # Обновляем позицию
    position += velocity * time_step
