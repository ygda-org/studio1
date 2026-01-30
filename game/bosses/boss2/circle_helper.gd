extends Node2D

var active = false
var boss

var SPEED = 250

func start(b):
	boss = b
	active = true
	get_parent().progress = 0
	
func _process(delta):
	if not active:
		return
	get_parent().progress = get_parent().progress + SPEED * delta
	if boss:
		boss.global_position = get_parent().global_position
		boss.segments[0].rotation = get_parent().rotation + PI/2
