extends Node3D

@export var INTENSITY := 8.0
@export var INTENSITY_VARIATION := 1.0

func _ready() -> void:
	for pieces : RigidBody3D in self.get_children():
		pieces.apply_impulse(pieces.get_child(0).position * (randf_range(-INTENSITY_VARIATION, INTENSITY_VARIATION) + INTENSITY), self.global_position)
	
	await get_tree().create_timer(5.0).timeout
	
	queue_free()
