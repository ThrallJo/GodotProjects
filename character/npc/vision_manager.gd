class_name VisionManager

extends Node3D

@export var sight_arc := 100.0
@export var max_sight_range := 100.0
@export var always_detect_in_range := 2.0

@onready var los_ray_cast: RayCast3D = $LOSRayCast
@onready var left_los_ray_cast: RayCast3D = $LeftLOSRayCast
@onready var right_los_ray_cast: RayCast3D = $RightLOSRayCast
@onready var visible_on_screen_notifier_3d: VisibleOnScreenNotifier3D = $VisibleOnScreenNotifier3D

var is_in_camera_vision := false

func _ready() -> void:
	left_los_ray_cast.position = visible_on_screen_notifier_3d.aabb.get_center()
	right_los_ray_cast.position = visible_on_screen_notifier_3d.aabb.get_center()
	left_los_ray_cast.position.x += visible_on_screen_notifier_3d.aabb.size.x
	right_los_ray_cast.position.x -= visible_on_screen_notifier_3d.aabb.size.x

## if need more than player can do can_see_target then pass in target
func can_see_target(target : Node3D):
	var target_pos = target.global_position + Vector3.UP * 1.5
	var dir_to_target = global_position.direction_to(target_pos)
	var dist_to_target = global_position.distance_to(target_pos)
	var fwd = -global_transform.basis.z
	
	if dist_to_target > max_sight_range:
		return false
	
	if dist_to_target < always_detect_in_range:
		return true
	
	if fwd.angle_to(dir_to_target) > deg_to_rad(sight_arc / 2.0):
		return false
	
	los_ray_cast.enabled = true
	los_ray_cast.target_position = los_ray_cast.to_local(target_pos)
	los_ray_cast.force_raycast_update()
	var has_los = !los_ray_cast.is_colliding()
	los_ray_cast.enabled = false
	
	return has_los
	
func is_facing_target(target : Node3D):
	var pos = to_local(target.global_position)
	return pos.z < 0.0 and abs(pos.x) < 0.5

func is_hidden_from_sight(target : Node3D) -> bool:
	if not is_in_camera_vision:
		return true
	
	# straight
	var target_pos = target.global_position + Vector3.UP * 1.5
	los_ray_cast.enabled = true
	los_ray_cast.target_position = los_ray_cast.to_local(target_pos)
	los_ray_cast.force_raycast_update()
	if !los_ray_cast.is_colliding(): return false
	los_ray_cast.enabled = false
	# left
	left_los_ray_cast.enabled = true
	left_los_ray_cast.target_position = left_los_ray_cast.to_local(target_pos)
	left_los_ray_cast.force_raycast_update()
	if !left_los_ray_cast.is_colliding(): return false
	left_los_ray_cast.enabled = false
	# right
	right_los_ray_cast.enabled = true
	right_los_ray_cast.target_position = right_los_ray_cast.to_local(target_pos)
	right_los_ray_cast.force_raycast_update()
	if !right_los_ray_cast.is_colliding(): return false
	right_los_ray_cast.enabled = false
	
	return true

func _on_visible_on_screen_notifier_3d_screen_entered() -> void:
	is_in_camera_vision = true


func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	is_in_camera_vision = false
