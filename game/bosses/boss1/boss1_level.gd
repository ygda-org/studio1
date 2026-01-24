extends "res://bosses/level.gd"

func start_game():
	super()
	var boss = load("uid://4gqrtfo36bvu").instantiate()
	boss.position = $ProjectilePosition.position
	boss.name = "Boss"
	var pos = Marker2D.new()
	pos.position = Vector2(0, -65)
	pos.name = "ProjectilePosition"
	add_child(pos)
	add_child(boss)
	set_positions.rpc(pos.position, boss.position)

@rpc ("call_local", "authority", "reliable")
func set_positions(pos1, pos2):
	get_node("ProjectilePosition").position = pos1
	get_node("Boss").position = pos2
