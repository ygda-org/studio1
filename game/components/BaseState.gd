extends Node2D
class_name BaseState

signal activating

@onready var states = get_parent()
@onready var boss = get_parent().get_parent()
var active = false
func activate():
	active = true
	activating.emit()

func deactivate():
	active = false
