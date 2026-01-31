extends BaseState

#var direction = Vector2(1,0)

@onready var path = boss.get_parent().get_node("CirclePath")

var last_rotation = 0

@onready var helper = boss.get_parent().get_node("CirclePath").get_node("PathFollow2D").get_node("CircleHelper")

const SPEED = 150
const SIZES = [null, 16, 16, 15, 15, 10, 14, 9, 7, 6, 7, 6]

func _ready():
	connect("activating", activation)

func activation():
	helper.start(boss)
	#boss.position = Vector2(-360, 0)
	#direction = Vector2(1,0)

func _process(delta):
	if not active:
		if helper:
			helper.active = active
		return
	if last_rotation != boss.segments[0].rotation:
		rotation_change(1)
	if boss.current_tick > 5:
		last_rotation = boss.segments[0].rotation
	for i in range(1, len(boss.base_rotations)-1):
		boss.segments[i].rotation = lerpf(boss.segments[i].rotation, boss.base_rotations[i], 120*delta*pow(SIZES[i],-1))

func rotation_change(seg):
	if seg >= len(boss.segments):
		return
	#boss.segments[seg].rotation = PI/2
	boss.base_rotations[seg] = PI/2
	if helper:
		$Timer.wait_time = float(SIZES[seg]) / helper.SPEED
		$Timer.seg_num = seg
		$Timer.start()


func _on_timer_timeout():
	boss.base_rotations[$Timer.seg_num] = 0
	#boss.segments[$Timer.seg_num].rotation = 0
	rotation_change($Timer.seg_num+1)
