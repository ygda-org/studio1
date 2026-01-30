extends BaseState

const SLAM_SPEED = 400

var slam_num = 0

@onready var extras = $Extras

func _ready():
	connect("activating", activation)

func activation():
	slam_num = 0
	$TimeBetween.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_time_between_timeout():
	extras.rotation = PI
	for n in extras.get_children():
		n.queue_free()
	$TimeBetween.start()
	boss.position = Vector2(0, -150)
	boss.segments[0].rotation = PI
	boss.velocity = Vector2(0, SLAM_SPEED)
	for i in range(slam_num):
		for n in boss.get_node("Polygons").get_children():
			var copy = n.duplicate()
			copy.position = n.position + Vector2(-14 + 50 * (1+i/2) * (1 if i % 2 == 0 else -1), 70+i*5)
			extras.add_child(copy)
	slam_num += 2
