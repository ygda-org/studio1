extends BaseState

var target
const DASH_SPEED = 200

func _ready():
	connect("activating", activation)

func _process(delta):
	if not active:
		return
	if active and $DashTimer.is_stopped():
		$DashTimer.start()
		dash()

func dash():
	states.get_parent().velocity = states.get_parent().global_position.direction_to(target.get_node("BasePlayer").global_position) * DASH_SPEED

func activation():
	target = GameState.players.pick_random()


func _on_visible_on_screen_notifier_2d_screen_exited():
	states.get_parent().velocity = Vector2.ZERO
