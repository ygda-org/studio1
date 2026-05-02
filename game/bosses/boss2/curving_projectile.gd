extends Area2D

var dmg = 12
const ROTATION_SPEED = 5*PI

const POSITION_TOLERANCE = 10 # distance at which projectile has reached target
var direction_change = false
const ACCELERATION_MULTIPLIER = 2
var finished = false

var target
var direction = 1

var velocity = Vector2(0,0)

@onready var target_position = global_position

@rpc ("authority", "call_local")
func initial_setup(start_pos, dir):
	global_position = start_pos
	direction = dir
	if NetworkState.is_server():
		target = GameState.players.pick_random()
		targeting.rpc(global_position + 2*(target.global_position-global_position)/3 + ((target.global_position-global_position)/2).rotated(PI/2*direction))

@rpc ("authority", "call_local")
func targeting(targ):
	target_position = targ

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotation += ROTATION_SPEED * delta * -direction
	velocity += (target_position - global_position) * delta * ACCELERATION_MULTIPLIER
	position += velocity * delta
	if NetworkState.is_server() and (position - target_position).length() < POSITION_TOLERANCE:
		if (not direction_change):
			direction_change = true
			targeting.rpc(target.global_position)
		else:
			finish.rpc()

@rpc ("authority", "call_local")
func finish():
	finished = true

func _on_visible_on_screen_notifier_2d_screen_exited():
	if finished or $MaxDur.is_stopped():
		queue_free()


func _on_absolute_max_dur_timeout():
	$AnimationPlayer.play("Fadeout")


func _on_body_entered(body):
	var damageable = body.find_child("EnemyDamageable")
	if damageable:
		damageable.hit(dmg)
		queue_free()
