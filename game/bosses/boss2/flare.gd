extends BaseState

const PROJECTILE = preload("uid://brhpjcmtbdjpf")

@onready var spawn_center = boss.get_parent().get_node("Phase4Center").global_position
const SPAWN_HEIGHT_DROP = 400 # distance to drop down from center for spawn pos

var spawn_positions = []
const LEVEL_OFFSETS = [90, 155, 280] # offsets from center in one direction, hard coded for each spawn position

func activate():
	super()
	if not NetworkState.is_server():
		return
	for offset in LEVEL_OFFSETS:
		spawn_positions.append(spawn_center.x + offset)
		spawn_positions.append(spawn_center.x - offset)
	shoot(spawn_positions.pick_random())
	$InBetween.start()


func _on_in_between_timeout():
	if active and NetworkState.is_server():
		$InBetween.start()
		shoot(spawn_positions.pick_random())


func shoot(pos):
	var proj = PROJECTILE.instantiate()
	proj.name = "BurstProj" + str(GameState.elapsed_time)
	boss.get_parent().add_child(proj)
	proj.set_vars.rpc(Vector2(0, -100), Vector2(pos, spawn_center.y + SPAWN_HEIGHT_DROP))
