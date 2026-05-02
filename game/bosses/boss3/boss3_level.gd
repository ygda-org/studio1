extends Level

func start_game():
	super()
	var boss = load("uid://cnn2tvrs7l0ql").instantiate()
	boss.name = "Boss"
	boss.position = Vector2(0,0)
	add_child(boss)
	boss.play_intro.rpc()
	play_intro.rpc()

@rpc ("authority", "call_local")
func play_intro():
	$AnimationPlayer.play("Intro")
