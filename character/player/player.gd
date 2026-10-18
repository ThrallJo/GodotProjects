class_name Player extends CharacterBody3D

@onready var camera_3d: Camera3D = $Camera3D
@onready var character_mover: Node3D = $CharacterMover
@onready var dev_console: DevConsole = $DevConsole
@onready var interact_raycast: RayCast3D = $Camera3D/InteractRaycast
@onready var sub_viewport_cam: Camera3D = %SubViewportCam

@export var mouse_sensitivity_h = 0.15
@export var mouse_sensitivity_v = 0.15

var _dir : Vector2

var dead = false

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	sub_viewport_cam.fov = camera_3d.fov
	sub_viewport_cam.size = camera_3d.size

func _input(event):
	if dead or dev_console.visible:
		return
	if event is InputEventMouseMotion:
		_dir.y -= event.relative.x * mouse_sensitivity_h
		_dir.x -= event.relative.y * mouse_sensitivity_v
		_dir = Vector2(clampf(_dir.x, -90.0, 90.0),wrapf(_dir.y, -360.0, 360.0))
		camera_3d.rotation_degrees = Vector3(_dir.x, 0.0, 0.0)
	
	if Input.is_action_just_pressed("attack"):
		# debug
		if interact_raycast.is_colliding():
			Global.log_print("Hit %s" % interact_raycast.get_collider().name)
		
		if interact_raycast.is_colliding() and interact_raycast.get_collider().has_method("hurt"):
			var damage = DamageData.new()
			damage.amount = 100
			damage.hit_pos = interact_raycast.get_collision_point()
			damage.damaged_by = self
			interact_raycast.get_collider().hurt(damage)

func _physics_process(_delta: float) -> void:
	rotation_degrees = Vector3(0.0, _dir.y, 0.0)

func _process(_delta):
	sub_viewport_cam.set_global_transform(camera_3d.get_global_transform())
	if dev_console.visible: return
	
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	if Input.is_action_just_pressed("restart"):
		get_tree().call_group("instanced", "queue_free")
		get_tree().reload_current_scene()
	if Input.is_action_just_pressed("fullscreen"):
		var fs = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
		if fs:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	if dead:
		return
	
	var input_dir = Input.get_vector("move_left", "move_right", "move_forwards", "move_backwards")
	var move_dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	character_mover.set_move_dir(move_dir)
	if Input.is_action_just_pressed("jump"):
		character_mover.jump()
	
