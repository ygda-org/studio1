extends BaseState

signal change_phase
var target
const DASH_SPEED = 200

const TOP_POSITION = Vector2(0, -220)
const BOTTOM_POSITION = Vector2(0, -30)
const LEFT_POSITION = Vector2(-210, -220)
const RIGHT_POSITION = Vector2(210, -220)

func _ready():
	connect("activating", activation)

func _process(delta):
	if active and target:
		dash(delta)

func dash(delta):
	if states.get_parent().global_position.distance_to(target) <= DASH_SPEED * delta * 5:
		states.get_parent().global_position = target
		set_boss_target(null)
		if NetworkState.is_server():
			$PhaseTimer.start()

@rpc ("call_local", "authority")
func set_boss_target(t):
	target = t
	if target:
		states.get_parent().velocity = states.get_parent().global_position.direction_to(target) * DASH_SPEED
	else:
		states.get_parent().velocity = Vector2.ZERO

func activation():
	if NetworkState.is_server():
		var possible_targets = [TOP_POSITION, LEFT_POSITION, RIGHT_POSITION, BOTTOM_POSITION]
		target = possible_targets[randi_range(0, possible_targets.size() - 1)]
		while states.get_parent().global_position.distance_to(target) < 100:
			target = possible_targets[randi_range(0, possible_targets.size() - 1)]
		set_boss_target.rpc(target) 


func _on_phase_timer_timeout() -> void:
	change_phase.emit()
