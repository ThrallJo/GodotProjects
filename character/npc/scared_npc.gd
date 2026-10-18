class_name ScaredNPC extends NPC

func _ready() -> void:
	super()
	set_state(STATES.IDLE)

func alert(alert_source):
	if alert_on_cooldown: return
	if alert_cooldown > 0: 
		alert_on_cooldown = true
		alert_cooldown_timer.start()
	
	if not cur_state in [STATES.ATTACK, STATES.DEAD, STATES.FLEE]:
		if has_node("Sounds/AlertSound"):
			$Sounds/AlertSound.play()
		last_known_alert_location = alert_source.global_position
		set_state(STATES.FLEE)
		#alert_nearby()
	elif cur_state in [STATES.FLEE]:
		find_random_spot(true)
