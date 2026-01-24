extends Node2D

var mouse_pos1
var mouse_pos2

signal gravity_attempt_grab
signal gravity_release

var last_input

func _ready():
	GameState.gravity_mage = self

func process_input(input):
	if input.right_click:
		mouse_pos1 = get_global_mouse_position()
	if not input.right_click and last_input and last_input.right_click:
		mouse_pos2 = get_global_mouse_position()
		var beble = load("res://players/gravity_mage/gravity_bubble.tscn").instantiate()
		beble.position = mouse_pos1
		beble.set_vector((mouse_pos2-mouse_pos1).normalized())
		beble.top_level = true
		add_child(beble)
	if input.left_click:
		gravity_attempt_grab.emit()
	if not input.left_click and last_input and last_input.left_click:
		gravity_release.emit()
	last_input = input
