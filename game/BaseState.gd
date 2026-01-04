extends Node2D
class_name BaseState

@onready var states = get_parent()
var active = false
func activate():
	active = true

func deactivate():
	active = false
