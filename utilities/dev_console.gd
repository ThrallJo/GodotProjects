class_name DevConsole extends CanvasLayer

@onready var text_input: LineEdit = %TextInput
@onready var console: RichTextLabel = %Console

var history: Array[String] = []
var history_index: int = -1

func _ready():
	#text_input.text_submitted.connect(self.on_run_command)
	hide()

func _process(_delta: float) -> void:
	on_input()

func on_input() -> void:
	if Input.is_action_just_pressed('dev_console_enter'):
		history.push_front(text_input.text)
		on_run_command(text_input.text)
		history_index = -1
		text_input.text = ''
		text_input.release_focus()
		text_input.grab_focus()
	elif Input.is_action_just_released('dev_console_prev'):
		if history.size() == 0:
			return
		history_index = clamp(history_index + 1, 0, history.size() - 1)
		text_input.text = history[history_index]
		# Hack to make the caret go to the end of the line
		# If I ever have a line of code over 100k characters, please send help
		text_input.caret_column = 100000
	elif Input.is_action_just_released('dev_console_next'):
		if history.size() == 0:
			return
		history_index = clamp(history_index - 1, 0, history.size() - 1)
		text_input.text = history[history_index]
		text_input.caret_column = 100000
	elif Input.is_action_just_pressed("dev_console_open"):
		if visible:
			hide()
			text_input.release_focus()
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			text_input.clear()
			show()
			text_input.grab_focus()
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func on_run_command(cmd: String) -> void:
	# Create an Expression instance
	var expression = Expression.new()
	var parse_error = expression.parse(cmd)
	if parse_error != OK:
		console.text += "\n" + str(parse_error)
		return

	# First parameter is for variables, which I don't need, so I just pass an empty array as the first parameter
	# Second parameter is the object that can provide additional context to the command
	# In this case, I have "reload" defined in the same script as my Expression, so I just pass "self"
	var result = expression.execute([], self)
	if result != null:
		console.text += "\n" + str(result)
	if expression.has_execute_failed():
		console.text += "\nInvalid command"

# Reload the current scene
func reload() -> void:
	get_tree().call_group("instanced", "queue_free")
	get_tree().reload_current_scene()

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
