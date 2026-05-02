extends BaseState

@onready var spawn_center = boss.get_parent().get_node("Phase4Center").global_position
const SPAWN_HEIGHT_DROP = 400 # distance to drop down from center for spawn pos

var spawn_positions = []
const LEVEL_OFFSETS = [80, 150, 290] # offsets from center in one direction, hard coded for each spawn position

func activate():
	super()
	if not NetworkState.is_server():
		return
	for offset in LEVEL_OFFSETS:
		spawn_positions.append(spawn_center + offset)
		spawn_positions.append(spawn_center - offset)
	shoot.rpc(spawn_positions.pick_random())


func _on_in_between_timeout():
	if active and NetworkState.is_server():
		$InBetween.start()
		shoot.rpc(spawn_positions.pick_random())

@rpc ("authority", "call_local")
func shoot():
	pass
