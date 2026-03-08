extends BaseState

var laser
var starting_rotation = PI
const ROTATE_SPEED = PI/8
const ROTATE_DISTANCE = PI/4

func activate():
	super()
	laser = load("uid://t6ptb3a68nj4").instantiate()
	boss.add_child(laser)
	laser.position.y -= 50
	boss.velocity = Vector2(0,0)
	boss.position = Vector2(0,-30)
	starting_rotation = boss.segments[0].rotation

func _process(delta):
	if not active:
		return
	boss.segments[0].rotation += ROTATE_SPEED * delta
	laser.rotation = boss.segments[0].rotation + PI
	#if laser.rotation > starting_rotation + ROTATE_DISTANCE:
	#	boss.phase_change.rpc()
