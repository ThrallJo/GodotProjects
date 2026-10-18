class_name DevConsole extends CanvasLayer

@onready var text_input: LineEdit = %TextInput
@onready var console: RichTextLabel = %Console
@onready var suggestion_text: RichTextLabel = %SuggestionText

var history: Array[String] = []
var history_index: int = -1

func _ready():
	Global.log_added.connect(update_log)
	suggestion_text.text = ""
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
	# Recontextualize the command for an expression
	var split_cmd := cmd.split(" ", false)
	if split_cmd.size() == 0:
		console.text += "\nInvalid command"
		return
	var actual_command := split_cmd[0] + "("
	for i in range(1, split_cmd.size()):
		if i > 1: actual_command += ", "
		actual_command += split_cmd[i]
	actual_command += ")"
	
	# Create an Expression instance
	var expression = Expression.new()
	var parse_error = expression.parse(actual_command)
	if parse_error != OK:
		console.text += "\n" + str(parse_error)
		return
	

	# First parameter is for variables, which I don't need, so I just pass an empty array as the first parameter
	# Second parameter is the object that can provide additional context to the command
	# In this case, I have "reload" defined in the same script as my Expression, so I just pass "self"
	var result = expression.execute([], Commands)
	if result != null:
		console.text += "\n" + str(result)
	if expression.has_execute_failed():
		console.text += "\nInvalid command"

func update_log(new_log : String):
	console.text += "\n" + new_log

func generate_suggestions() -> void:
	suggestion_text.text = ""
	if text_input.text.length() == 0:
		return
	var matches = []
	var match_string := text_input.text
	
	for method in Commands.autocomplete_methods:
		if method.contains(match_string):
			matches.append(method)
	
	for amatch in matches:
		suggestion_text.text += amatch + "\n"


func _on_text_input_text_changed(_new_text: String) -> void:
	generate_suggestions()
