class_name NPC extends CharacterBody3D

@onready var ai_character_mover: AICharacterMover = $AICharacterMover
@onready var vision_manager: VisionManager = $VisionManager

@export var animation_player : AnimationPlayer
@onready var player = get_tree().get_first_node_in_group("player")

enum STATES {IDLE, ATTACK, DEAD}
var cur_state = STATES.IDLE

@export var attack_range := 2.0
@export var damage := 15

@export var attack_speed_modifier := 1.0

func _ready():
	#var hitboxes = find_children("*", "HitBox")
	#for hitbox in hitboxes:
		#hitbox.on_hurt.connect(health_manager.hurt)
	#health_manager.died.connect(set_state.bind(STATES.DEAD))
	#health_manager.gibbed.connect(queue_free)
	#
	#hitboxes.append(self)
	#bullet_emitter.set_bodies_to_exclude(hitboxes)
	#bullet_emitter.set_damage(damage)
	
	set_state(STATES.IDLE)

#func hurt(damage_data : DamageData):
	#health_manager.hurt(damage_data)

func alert():
	# keeping as this so that I remember I can do this
	# may be better to do if cur_state == STATES.IDLE
	if not cur_state in [STATES.ATTACK, STATES.DEAD]:
		$AlertSound.play()
		set_state(STATES.ATTACK)
		#alert_nearby_monsters()

func set_state(state: STATES):
	if cur_state == STATES.DEAD:
		return
	cur_state = state
	match cur_state:
		STATES.ATTACK:
			pass
		STATES.IDLE:
			animation_player.play("idle")
		STATES.DEAD:
			animation_player.play("die", 0.2)
			collision_layer = 0
			collision_mask = 1
			ai_character_mover.stop_moving()

func _process(delta):
	match cur_state:
		STATES.IDLE:
			process_idle_state(delta)
		STATES.ATTACK:
			process_attack_state(delta)

func process_idle_state(delta):
	if vision_manager.can_see_target(player):
		alert()

func process_attack_state(delta):
	pass
