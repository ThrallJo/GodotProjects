extends Node

var autocomplete_methods: Array = []

func _ready() -> void:
	autocomplete_methods = get_script().get_script_method_list().map(
		func (x): 
			var method = x.name
			for arg in x.args:
				method += " <" + arg.name + ">"
			return method
	)
	get_script().get_script_method_list()

# Reload the current scene
func reload() -> void:
	get_tree().call_group("instanced", "queue_free")
	get_tree().reload_current_scene()

func quit() -> void:
	get_tree().quit()

func toggle_time() -> String:
	var time_node = get_tree().get_first_node_in_group("DayNightCycle") as DayNightCycle
	if time_node == null: return "DayNightCycle node not found."
	
	if time_node.toggle_time_freeze():
		return "Time frozen!"
	else:
		return "Time resumed!"
	
func set_time(hour : float) -> String:
	var time_node = get_tree().get_first_node_in_group("DayNightCycle") as DayNightCycle
	if time_node == null: return "DayNightCycle node not found."
	
	time_node.set_time(hour)
	return "Time set to %s." % hour

func set_time_rate(time_rate : float) -> String:
	var time_node = get_tree().get_first_node_in_group("DayNightCycle") as DayNightCycle
	if time_node == null: return "DayNightCycle node not found."
	
	var old_time_rate = time_node.time_rate
	time_node.time_rate = time_rate
	return "Time rate changed from %s to %s." % [old_time_rate, time_rate]
