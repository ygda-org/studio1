extends Node2D

var front_seg

var velocity = Vector2(0,0)

const SPEED = 200

# Called when the node enters the scene tree for the first time.
func _ready():
	var last_seg = null
	for i in range(5):
		var seg = load("uid://dne37ue311bbo").instantiate()
		if i == 0:
			front_seg = seg
		seg.position = Vector2(i * -100, i * 60)
		seg.front = last_seg
		if last_seg:
			last_seg.back = seg
		last_seg = seg
		add_child(seg)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if front_seg:
		velocity = delta*SPEED*(global_position.direction_to(get_global_mouse_position()))
		front_seg.position += velocity
