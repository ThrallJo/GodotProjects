class_name WeaponManager extends Node3D

@export var start_unlocked := true

@onready var weapons = $Weapons.get_children()
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var weapons_unlocked = []
var cur_slot = 0
var cur_weapon = null

signal weapon_unlocked

func _ready():
	for weapon in weapons:
		if weapon.has_method("set_bodies_to_exclude"):
			weapon.set_bodies_to_exclude([get_parent().get_parent()])
	
	if not start_unlocked: disable_all_weapons()
	# doing the underscore so that we don't get the godot warning
	for i in range(weapons.size()):
		weapons_unlocked.append(start_unlocked)

func attack(input_just_pressed : bool, input_held : bool):
	if cur_weapon is Weapon:
		cur_weapon.attack(input_just_pressed, input_held)

func enable_weapon(weapon_index : int):
	if weapon_index >= weapons_unlocked.size():
		printerr("Unlocking non-existant weapon %s", weapon_index)
		return
	weapons_unlocked[weapon_index] = true
	weapons[weapon_index].show()
	weapons[weapon_index].animation_player.play("pickup")
	weapon_unlocked.emit(weapon_index)
	if weapons[weapon_index].has_node("EquipSound"):
		weapons[weapon_index].get_node("EquipSound").play()
	

func disable_all_weapons():
	for weapon in weapons:
		if weapon.has_method("set_active"):
			weapon.set_active(false)
		else:
			weapon.hide()

func update_animation(velocity: Vector3, grounded: bool):
	if cur_weapon is Weapon and !cur_weapon.is_idle():
		animation_player.play("RESET")
	elif !grounded or velocity.length() < 5.0:
		animation_player.play("RESET", 0.3)
	else:
		animation_player.play("moving", 0.3)
