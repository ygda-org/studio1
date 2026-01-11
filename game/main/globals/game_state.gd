extends Node



func log(message: String) -> void:
	print_rich("[color=white][LOG][/color] " + message)

func critical(message: String) -> void:
	print_rich("[color=yellow][CRITICAL][/color] " + message)

func error(message: String) -> void:
	print_rich("[color=red][ERROR][/color] " + message)
