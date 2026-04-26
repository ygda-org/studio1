extends BaseState

const SPEED = 100

@export var bounce_shape: Shape2D

var bounce

func activate():
	super()
	$StartTimer.start()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not active:
		return
	if bounce:
		bounce.rotation = boss.segments[0].rotation

func _on_start_timer_timeout():
	bounce = load("uid://boh7edtc42xte").instantiate()
	var bounce_coll = CollisionShape2D.new()
	bounce_coll.shape = bounce_shape
	bounce.add_child(bounce_coll)
	add_child(bounce)
	boss.get_node("States").queue_free()
	boss.get_node("States2").queue_free() # to clear clones
	$BounceQueueFreeTimer.start()
	$AnimationPlayer.play("transition")



func _on_animation_player_animation_finished(anim_name):
	if NetworkState.is_server() and anim_name == 'transition':
		boss.die.rpc()


func _on_bounce_queue_free_timer_timeout():
	bounce.queue_free()
