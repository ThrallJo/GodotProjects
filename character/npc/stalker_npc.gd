class_name StalkerNPC extends NPC

func _ready():
	super()
	set_state(STATES.ATTACK)

func process_attack_state(_delta):
	# Only start moving if not in sight of the player
	if not vision_manager.is_hidden_from_sight(player):
		animation_player.play("idle")
		ai_character_mover.stop_moving()
		return
	
	var attacking = animation_player.current_animation == "attack"
	var vec_to_player = player.global_position - global_position
	
	if vec_to_player.length() <= attack_range:
		ai_character_mover.stop_moving()
		if !attacking and vision_manager.is_facing_target(player):
			start_attack()
		elif !attacking:
			ai_character_mover.set_facing_dir(vec_to_player)
	elif !attacking:
		ai_character_mover.set_facing_dir(ai_character_mover.move_dir)
		ai_character_mover.move_to_point(player.global_position)
		animation_player.play("walk", -1, 0.5)
	
