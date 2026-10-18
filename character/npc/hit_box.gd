class_name HitBox
extends Area3D

@export var is_weak_spot := false
@export var is_shell_spot := false
@export var shell_spot_health := 1
@export var critical_damage_multiplier = 2
signal on_hurt(damage_data : DamageData)

func hurt(damage_data : DamageData):
	if is_weak_spot:
		damage_data.amount *= critical_damage_multiplier
	if is_shell_spot:
		shell_spot_health -= damage_data.amount
		damage_data.amount = 0
		
	# TODO: Emit if shell was destroyed
	on_hurt.emit(damage_data)
	
	if shell_spot_health <= 0:
		#TODO: Animate shattering
		get_parent().queue_free()
