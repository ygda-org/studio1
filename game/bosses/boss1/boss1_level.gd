extends "res://bosses/level.gd"

var map = 1

func start_game():
	super()
	var boss = load("uid://4gqrtfo36bvu").instantiate()
	boss.position = $ProjectilePosition.position
	boss.name = "Boss"
	var pos = Marker2D.new()
	boss.next_phase.connect(next_phase)
	add_child(boss)
	set_positions.rpc(boss.position)

@rpc ("call_local", "authority", "reliable")
func set_positions(pos1):
	get_node("Boss").position = pos1

func next_phase():
	if NetworkState.is_server():
		change_map.rpc()

@rpc ("call_local", "authority", "reliable")
func change_map():
	map += 1
	if map == 2:
		$Phase1.enabled = false
		$Phase1.visible = false
		$Phase2.enabled = true
		$Phase2.visible = true

#@rpc ("call_local", "authority", "reliable")
#func set_positions(pos1, pos2):
	#get_node("ProjectilePosition").position = pos1
	#get_node("Boss").position = pos2
