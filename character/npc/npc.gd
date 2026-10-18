class_name NPC extends CharacterBody3D

@onready var ai_character_mover: AICharacterMover = $AICharacterMover
@onready var vision_manager: VisionManager = $VisionManager
@onready var health_manager: Node3D = $HealthManager

@export var animation_player : AnimationPlayer
@onready var player = get_tree().get_first_node_in_group("player") as Player

enum STATES {IDLE, WANDER, ATTACK, FLEE, DEAD}
var last_known_alert_location := Vector3.ZERO
var chosen_random_spot := Vector3.ZERO
var cur_state = STATES.IDLE

@export_category("Attack State")
@export var attack_range := 2.0
@export var damage := 15
@export var attack_speed_modifier := 1.0

@export_category("Wander State")
@export var can_wander := true
@export_range(0.0, 10.0) var boredom_time := 5.0
@export_range(1.0, 100.0) var min_wander_range := 5.0
@export_range(1.0, 100.0) var max_wander_range := 10.0
var time_until_wander := boredom_time

@export_category("Flee State")
@export_range(1.0, 100.0) var min_flee_range := 20.0
@export_range(1.0, 100.0) var max_flee_range := 30.0
@export_range(0.0, 180.0) var flee_angle_limit := 15.0
@export_range(0.0, 60.0) var time_to_calm := 10.0
var time_until_calm = 0.0

@export_category("Misc")
@export_range(0.0, 60.0) var alert_cooldown := 1.0
var alert_on_cooldown := false
@onready var alert_cooldown_timer: Timer = $AlertCooldown


@export_category("Debug")
@export var is_verbose := false
@export var show_pathing := false
@onready var debug_points: Node3D = $DebugPoints
@onready var destination_indicator: MeshInstance3D = $DebugPoints/DestinationIndicator

func _ready():
	alert_cooldown_timer.wait_time = alert_cooldown
	destination_indicator.top_level = true
	debug_points.visible = show_pathing
	ai_character_mover.navigation_agent_3d.debug_enabled = show_pathing
	destination_indicator.hide()
	var hitboxes = find_children("*", "HitBox")
	for hitbox in hitboxes:
		hitbox.on_hurt.connect(health_manager.hurt)
	#health_manager.died.connect(set_state.bind(STATES.DEAD))
	#health_manager.gibbed.connect(queue_free)
	#
	#hitboxes.append(self)
	#bullet_emitter.set_bodies_to_exclude(hitboxes)
	#bullet_emitter.set_damage(damage)
	
	set_state(STATES.ATTACK)

#func hurt(damage_data : DamageData):
	#health_manager.hurt(damage_data)

func alert(alert_source):
	if alert_on_cooldown: return
	if alert_cooldown > 0: 
		alert_on_cooldown = true
		alert_cooldown_timer.start()
	
	
	if not cur_state in [STATES.ATTACK, STATES.DEAD]:
		if has_node("Sounds/AlertSound"):
			$Sounds/AlertSound.play()
		last_known_alert_location = alert_source.global_position
		set_state(STATES.ATTACK)
		#alert_nearby_monsters()

func set_state(state: STATES):
	if state == cur_state: return
	if is_verbose: Global.log_print("Set %s's state to %s." % [name, STATES.keys()[state]])
	if cur_state == STATES.DEAD:
		return
	cur_state = state
	match cur_state:
		STATES.ATTACK:
			destination_indicator.show()
		STATES.IDLE:
			animation_player.play("idle")
			destination_indicator.hide()
		STATES.DEAD:
			animation_player.play("die", 0.2)
			collision_layer = 0
			collision_mask = 1
			ai_character_mover.stop_moving()
			destination_indicator.hide()
		STATES.FLEE:
			time_until_calm = time_to_calm
			destination_indicator.show()
			find_random_spot(true)
		STATES.WANDER:
			destination_indicator.show()
			find_random_spot(false)

func _process(delta):
	match cur_state:
		STATES.IDLE:
			process_idle_state(delta)
		STATES.ATTACK:
			process_attack_state(delta)
		STATES.FLEE:
			process_flee_state(delta)
		STATES.WANDER:
			process_wander_state(delta)

func process_idle_state(_delta):
	if vision_manager.can_see_target(player):
		alert(player)
	
	if not can_wander: return
	time_until_wander -= _delta
	if time_until_wander < 0:
		time_until_wander = boredom_time
		set_state(STATES.WANDER)

func process_attack_state(_delta):
	pass

func process_flee_state(_delta):
	# NPC picks a random point away from what scared them and runs towards it.
	if vision_manager.can_see_target(player):
		alert(player)
	
	time_until_calm -= _delta
	if time_to_calm > 0 and time_until_calm <= 0:
		set_state(STATES.WANDER)
	
	var vec_to_destination = chosen_random_spot - global_position
	if vec_to_destination.length() <= 1.2:
		ai_character_mover.stop_moving()
		ai_character_mover.set_facing_dir(vec_to_destination)
		find_random_spot(true)
	else:
		ai_character_mover.set_facing_dir(ai_character_mover.move_dir)
		ai_character_mover.move_to_point(chosen_random_spot)
		animation_player.play("walk", -1, 2.0)

func process_wander_state(_delta):
	if vision_manager.can_see_target(player):
		alert(player)
	
	var vec_to_destination = chosen_random_spot - global_position
	if vec_to_destination.length() <= 1.2:
		ai_character_mover.stop_moving()
		ai_character_mover.set_facing_dir(vec_to_destination)
		set_state(STATES.IDLE)
	else:
		ai_character_mover.set_facing_dir(ai_character_mover.move_dir)
		ai_character_mover.move_to_point(chosen_random_spot)
		animation_player.play("walk", -1, 0.5)

func find_random_spot(is_fleeing := false) -> Vector3:
	var random_angle = randf_range(0, 360.0)
	var distance = randf_range(min_wander_range, max_wander_range)
	destination_indicator.transform = global_transform
	
	if is_fleeing: 
		distance = randf_range(min_flee_range, max_flee_range)
		random_angle = randf_range(-flee_angle_limit, flee_angle_limit)
		var alert_vector := (global_position - last_known_alert_location).normalized()
		destination_indicator.transform = destination_indicator.transform.rotated(Vector3.UP, random_angle)
		destination_indicator.transform.origin = destination_indicator.to_global(alert_vector * (distance))
	else:
		destination_indicator.transform = destination_indicator.transform.rotated(Vector3.UP, random_angle)
		destination_indicator.transform.origin = destination_indicator.to_global(Vector3.FORWARD * (distance))
		
	
	# get the point right inbetween the range so it encapsulates the whole range
	chosen_random_spot = destination_indicator.transform.origin
	
	
	var map_rid := NavigationServer3D.agent_get_map(ai_character_mover.navigation_agent_3d.get_rid())
	if map_rid.is_valid():
		chosen_random_spot = NavigationServer3D.map_get_closest_point(map_rid, chosen_random_spot)
	destination_indicator.global_position = chosen_random_spot
	return chosen_random_spot

func start_attack():
	if has_node("Sounds/AttackSound"):
		$Sounds/AttackSound.play()
	animation_player.play("attack", -1, attack_speed_modifier)


func _on_alert_cooldown_timeout() -> void:
	alert_on_cooldown = false
