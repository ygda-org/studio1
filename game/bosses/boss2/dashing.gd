extends BaseState

var target
const DASH_SPEED = 200

func _ready():
	connect("activating", activation)

func _process(delta):
	if not active:
		return
	if active and $StartTime.is_stopped():
		states.get_parent().velocity = states.get_parent().velocity.lerp(states.get_parent().front_seg.global_position.direction_to(target.global_position) * DASH_SPEED, delta)
		#$DashTimer.start()
		#dash()

func dash():
	if target:
		states.get_parent().velocity = states.get_parent().front_seg.global_position.direction_to(target.global_position) * DASH_SPEED

func activation():
	$StartTime.start()

func _on_vis_screen_exited():
	states.get_parent().velocity /= 3


func _on_start_time_timeout():
	target = GameState.players.pick_random()
