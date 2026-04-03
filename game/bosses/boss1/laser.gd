extends BaseState

signal change_phase

const ROTATE_SPEED = 100

func _ready():
	connect("activating", activation)
	
	
func activation():
	$PhaseTimer.start(randf_range(4, 8))
	$LaserCD.start()
	fire()

@rpc ("authority", "call_local")
func shoot(start_dir, rotation_speed, double):
	var laser = load("res://bosses/boss1/laser.tscn").instantiate()
	laser.global_position = get_parent().global_position
	laser.rotation = start_dir - deg_to_rad(rotation_speed) * ($LaserCD.wait_time - 1) / 2
	laser.rotation_speed = rotation_speed
	states.get_parent().get_parent().add_child(laser, true)
	if double:
		var laser2 = load("res://bosses/boss1/laser.tscn").instantiate()
		laser2.global_position = get_parent().global_position
		laser2.rotation = PI - (start_dir - deg_to_rad(rotation_speed) * ($LaserCD.wait_time - 1) / 2)
		laser2.rotation_speed = rotation_speed * -1
		states.get_parent().get_parent().add_child(laser2, true)

func pick_shot():
	var target
	var double
	if abs(global_position.x) < 100:
		double = true
		var horizontal = randi_range(-1, 1)
		if global_position.y > 0:
			target = Vector2(horizontal + global_position.x, global_position.y - 50)
		else:
			target = Vector2(horizontal + global_position.x, global_position.y + 50)
	else:
		target = GameState.players.pick_random().global_position
		double = false
	var direction = global_position.direction_to(target).angle()
	shoot.rpc(direction, randi_range(25, 35) * (randi_range(0, 1) * 2 - 1), double)

func _on_phase_timer_timeout() -> void:
	change_phase.emit()

func _on_laser_cd_timeout() -> void:
	fire()

func fire():
	if active and NetworkState.is_server():
		pick_shot()
