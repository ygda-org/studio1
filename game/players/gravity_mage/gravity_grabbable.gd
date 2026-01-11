extends Area2D

# area is area for which it can be grabbed
# to be added as child of body

var mouse_selected = false
var grabbed = false

@export var follow_speed: float = 4.0
@export var max_speed: float = 600.0


func _process(delta):
	if GameState.gravity_mage and not GameState.gravity_mage.is_connected("gravity_attempt_grab", grab) and not GameState.gravity_mage.is_connected("gravity_release", release):
		GameState.gravity_mage.connect("gravity_attempt_grab", grab)
		GameState.gravity_mage.connect("gravity_release", release)
	if grabbed and GameState.gravity_mage:
		get_parent().velocity += get_parent().global_position.direction_to(GameState.gravity_mage.get_parent().mouse_position) * follow_speed * abs(GameState.gravity_mage.get_parent().mouse_position-get_parent().global_position) * delta
		if abs(get_parent().velocity.length()) > max_speed:
			get_parent().velocity = get_parent().velocity.normalized() * max_speed

func grab():
	if mouse_selected:
		grabbed = true

func release():
	grabbed = false

func _on_mouse_entered():
	mouse_selected = true

func _on_mouse_exited():
	mouse_selected = false
