extends "res://bosses/level.gd"

func start_game():
	super()
	var boss = load("uid://4gqrtfo36bvu").instantiate()
	boss.position = $ProjectilePosition.position
	add_child(boss)
