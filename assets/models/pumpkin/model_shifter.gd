extends Node3D

@export var broken_model : PackedScene

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("action"):
		var broken_model_inst := broken_model.instantiate()
		get_parent().add_child(broken_model_inst)
		broken_model_inst.transform = self.transform
		
		queue_free()
