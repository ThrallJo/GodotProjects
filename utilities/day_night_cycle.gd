@tool
class_name DayNightCycle extends Node3D

var true_time : float
var time_rate : float

@export_category("Time")
@export var is_time_frozen := false
@export var day_length : float = 20.0:
	set(value):
		day_length = value
		if Engine.is_editor_hint():
			time_rate = 1.0 / day_length
			regenerate_daytime()
@export_range(0, 1.0) var start_time : float = 0.3:
	set(value):
		start_time = value
		if Engine.is_editor_hint():
			true_time = start_time
			regenerate_daytime()
@export var time_curve : Curve

@export_category("Sun/Moon")
# sun
@export_group("Sun")
@onready var sun: DirectionalLight3D = $Sun
@export var sun_color : Gradient
@export var sun_intensity : Curve

# moon
@export_group("Moon")
@onready var moon: DirectionalLight3D = $Moon
@export var moon_color : Gradient
@export var moon_intensity : Curve

#environment
@export_group("Sky")
@onready var environment: WorldEnvironment = $WorldEnvironment
@export var sky_top_color : Gradient
@export var sky_horizon_color : Gradient

@export_category("Night adjustments")
@export_group("Depth of Field")
@export var dof_enabled := true:
	set(value):
		dof_enabled = value
		if Engine.is_editor_hint():
			environment.camera_attributes.dof_blur_far_enabled = dof_enabled
			regenerate_daytime()
@export var dof_falloff : Curve
@export var dof_far_distance := 20.0:
	set(value):
		dof_far_distance = value
		if Engine.is_editor_hint():
			environment.camera_attributes.dof_blur_far_distance = dof_far_distance
			regenerate_daytime()

@export_group("Adjustments")
@export var brightness : Curve
@export var contrast : Curve
@export var saturation : Curve

func _ready() -> void:
	time_rate = 1.0 / day_length
	true_time = start_time
	environment.camera_attributes.dof_blur_far_enabled = dof_enabled

### Gets variable of the hour and converts it to time
func set_time(hour : float):
	true_time = hour / 24

func toggle_time_freeze() -> bool:
	is_time_frozen = !is_time_frozen
	return is_time_frozen

func _process(delta: float) -> void:
	if not is_time_frozen: true_time += time_rate * delta
	calculate_daytime()

func regenerate_daytime():
	if Engine.is_editor_hint():
		# if you need to cleanup anything put it here
		# wait for cleanup
		if get_tree() != null:
			await get_tree().process_frame
		calculate_daytime()

func calculate_daytime():
	if true_time >= 1.0:
		true_time = 0.0
	
	var time = time_curve.sample(true_time)
	sun.rotation_degrees.x = (time * 360) + 90
	sun.light_color = sun_color.sample(time)
	sun.light_energy = sun_intensity.sample(time)
	
	moon.rotation_degrees.x = (time * 360) - 90
	moon.light_color = moon_color.sample(time)
	moon.light_energy = moon_intensity.sample(time)
	
	sun.visible = sun.light_energy > 0
	moon.visible = moon.light_energy > 0
	
	# setting the sky color
	environment.environment.sky.sky_material.set("sky_top_color", sky_top_color.sample(time))
	environment.environment.sky.sky_material.set("sky_horizon_color", sky_horizon_color.sample(time))
	environment.environment.sky.sky_material.set("ground_bottom_color", sky_top_color.sample(time))
	environment.environment.sky.sky_material.set("ground_horizon_color", sky_horizon_color.sample(time))
	
	# setting Depth of Field
	if dof_enabled:
		environment.camera_attributes.dof_blur_amount = dof_falloff.sample(1 - sun.light_energy)
	
	#if contrast != null: environment.environment.adjustment_contrast = contrast.sample(sun.light_energy)
