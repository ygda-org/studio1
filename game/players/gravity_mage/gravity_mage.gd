extends Node2D

var mouse_pos1
var mouse_pos2

func _process(delta):
	if Input.is_action_just_pressed("right_click"):
		mouse_pos1 = get_global_mouse_position()
	if Input.is_action_just_released("right_click"):
		mouse_pos2 = get_global_mouse_position()
		var beble = load("res://players/gravity_mage/gravity_bubble.tscn").instantiate()
		beble.position = mouse_pos1
		beble.set_vector((mouse_pos2-mouse_pos1).normalized())
		add_child(beble)
