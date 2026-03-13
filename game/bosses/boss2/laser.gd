extends BaseState

var laser
const ROTATE_SPEED = PI/8

func activate():
	super()
	laser = load("uid://t6ptb3a68nj4").instantiate()
	if NetworkState.is_server():
		$LaserTimer.start()
	boss.add_child(laser)
	laser.position.y -= 50
	boss.velocity = Vector2(0,0)
	boss.position = Vector2(0,-30)
	set_rot.rpc(randf_range(2*PI/4, 3*PI/4))

@rpc ("call_local", "authority")
func set_rot(rot):
	boss.segments[0].rotation = rot

func _process(delta):
	if not active:
		return
	boss.segments[0].rotation += ROTATE_SPEED * delta
	laser.rotation = boss.segments[0].rotation + PI


func _on_laser_timer_timeout() -> void:
	boss.phase_change.rpc()
	laser.suicide.rpc()
	laser = null
