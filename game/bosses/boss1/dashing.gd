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
	if not active:
		return
	if active and target:
		dash(delta)

func dash(delta):
	states.get_parent().velocity = states.get_parent().global_position.direction_to(target) * DASH_SPEED
	if states.get_parent().global_position.distance_to(target) <= DASH_SPEED * delta * 5:
		target = null
		states.get_parent().velocity = Vector2.ZERO
		states.get_parent().velocity = target
		if NetworkState.is_server():
			change_phase.emit()

func activation():
	var possible_targets = [TOP_POSITION, LEFT_POSITION, RIGHT_POSITION, BOTTOM_POSITION]
	target = possible_targets[randi_range(0, possible_targets.size() - 1)]
	while states.get_parent().global_position.distance_to(target) < 100:
		target = possible_targets[randi_range(0, possible_targets.size() - 1)]
