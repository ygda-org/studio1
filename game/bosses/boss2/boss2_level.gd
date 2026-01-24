extends "res://bosses/level.gd"

func start_game():
	super()
	var boss = load("uid://bmq26vykccdr8").instantiate()
	boss.name = "Boss"
	boss.position = Vector2(0,0)
	add_child(boss)

#@rpc ("call_local", "authority", "reliable")
#func set_positions(pos1, pos2):
#	get_node("ProjectilePosition").position = pos1
#	get_node("Boss").position = pos2
