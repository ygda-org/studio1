extends BaseState

const SLAM_SPEED = 700

var slam_num = 0

const TELEGRAPH = preload("uid://doeas68favqnr")

@onready var extras = $Extras

func _ready():
	connect("activating", activation)

func activation():
	slam_num = 0
	$TimeBetween.start()

func _on_time_between_timeout():
	if NetworkState.is_server() and active:
		slam.rpc()

@rpc ("call_local", "authority")
func slam():
	for n in extras.get_children():
		n.queue_free()
	if slam_num > 9:
		if NetworkState.is_server():
			boss.phase_change.rpc()
		slam_num = 0
		return
	extras.rotation = PI
	$TimeBetween.start()
	boss.position = Vector2(10++randi_range(-30,30), -400)
	boss.segments[0].rotation = PI
	boss.velocity = Vector2(0, SLAM_SPEED)
	var tele = TELEGRAPH.instantiate()
	extras.add_child(tele)
	for i in range(slam_num):
		var copy
		for n in boss.get_node("Polygons").get_children():
			copy = n.duplicate()
			copy.position = n.position + Vector2(70.0 * (1.0+i/2.0) * (1.0 if i % 2 == 0 else -1.0), 70.0+i*5)
			copy.z_index = -1
			extras.add_child(copy)
		var telegraph = TELEGRAPH.instantiate()
		telegraph.position.x += 20
		copy.add_child(telegraph)
	slam_num += 2
