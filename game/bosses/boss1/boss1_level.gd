extends "res://bosses/level.gd"

func start_game():
	super()
	var boss = load("uid://4gqrtfo36bvu").instantiate()
	boss.position = $ProjectilePosition.position
	boss.name = "Boss"
	var pos = Marker2D.new()
	add_child(boss)
	set_positions.rpc(boss.position)

@rpc ("call_local", "authority", "reliable")
func set_positions(pos1):
	get_node("Boss").position = pos1

#@rpc ("call_local", "authority", "reliable")
#func set_positions(pos1, pos2):
	#get_node("ProjectilePosition").position = pos1
	#get_node("Boss").position = pos2
