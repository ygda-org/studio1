extends BaseState

const DASH_SPEED = 200

var leaving_screen = false

func _ready():
	connect("activating", activation)

func activation():
	leaving_screen = true
	$Startup.start()
	boss.velocity = Vector2(0, -150)
	#boss.segments[0].rotation = 0

func _process(delta):
	if leaving_screen:
		if boss.segments[0].rotation > PI:
			boss.segments[0].rotation = lerpf(boss.segments[0].rotation, 0, delta*5)
		else:
			boss.segments[0].rotation = lerpf(boss.segments[0].rotation, 0, -delta*5)

func _on_startup_timeout():
	leaving_screen = false
	if NetworkState.is_server():
		dash.rpc((randi_range(0,1) * 2) - 1, randi_range(-100, 100))

@rpc ("authority", "call_local")
func dash(dir, x_pos):
	boss.segments[0].rotation = PI + PI/4 * -dir
	boss.velocity = Vector2(DASH_SPEED*dir, DASH_SPEED)
	boss.position = Vector2(x_pos, -200)



func _on_visible_on_screen_notifier_2d_screen_exited():
	$Cooldown.start()


func _on_cooldown_timeout():
	if NetworkState.is_server() and active and $Startup.is_stopped():
		dash.rpc((randi_range(0,1) * 2) - 1, randi_range(-150, 150))
