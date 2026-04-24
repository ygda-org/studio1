extends BaseState

const SPEED = 100

func activate():
	super()
	$StartTimer.start()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not active:
		return
	

func _on_start_timer_timeout():
	$AnimationPlayer.play("transition")



func _on_animation_player_animation_finished(anim_name):
	if NetworkState.is_server() and anim_name == 'transition':
		boss.die.rpc()
