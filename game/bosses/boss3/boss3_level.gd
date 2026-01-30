extends "res://bosses/level.gd"

func start_game():
	super()
	var boss = load("uid://cnn2tvrs7l0ql").instantiate()
	boss.name = "Boss"
	boss.position = Vector2(0,0)
	add_child(boss)
