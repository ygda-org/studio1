extends Area2D

# area is area for which it can be grabbed
# to be added as child of body

var mouse_selected = false
var grabbed = false

@export var follow_speed: float = 4.0
@export var max_speed: float = 600.0


func _process(_delta):
	if GameState.ninja_mage and not GameState.ninja_mage.is_connected("ninja_attempt_attempt", swap):
		GameState.ninja_mage.connect("ninja_attempt_swap", swap)
	

func swap():
	if mouse_selected:
		GameState.ninja_swap.rpc(self)

func _on_mouse_entered():
	mouse_selected = true

func _on_mouse_exited():
	mouse_selected = false

@rpc
func ninja_swap(other):
	var temp = get_parent().global_position
	get_parent().global_position = other.get_parent().global_position
	other.get_parent().global_position = temp
