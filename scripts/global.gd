extends Node

var logs : Array[String]
signal log_added
func log_print(msg : String) -> void:
	print(msg)
	logs.append(msg)
	log_added.emit(msg)

func log_error_print(msg : String) -> void:
	printerr(msg)
	logs.append(msg)
	log_added.emit(msg)
