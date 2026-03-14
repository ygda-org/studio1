extends "res://components/BaseState.gd"

const SPEED = 100

func activate():
	super()
	$StartTimer.start()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not active:
		return
	

func _on_start_timer_timeout():
	boss.velocity.y = SPEED
