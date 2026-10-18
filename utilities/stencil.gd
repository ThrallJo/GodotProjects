@tool
extends Node3D

@export var target_camera: Camera3D = null
@export var mask_camera : Camera3D = null
@export var mask_viewport : SubViewport

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		var editor_viewport = EditorInterface.get_editor_viewport_3d(0)
		var editor_camera = editor_viewport.get_camera_3d();
		
		mask_camera.global_transform = editor_camera.global_transform
		mask_camera.fov = editor_camera.fov
		mask_viewport.size = editor_viewport.size
		
	elif target_camera != null:
		mask_camera.global_transform = target_camera.global_transform
		mask_camera.fov = target_camera.fov
		mask_viewport.size = get_viewport().size
