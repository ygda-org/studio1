extends Node2D

var front_seg

var velocity = Vector2(0,0)

@onready var phases = $States.get_children()
var current_phase = 0
var current_tick = 0

const SPEED = 200

# Called when the node enters the scene tree for the first time.
func _ready():
	var last_seg = null
	for i in range(5):
		var seg = load("uid://dne37ue311bbo").instantiate()
		if i == 0:
			front_seg = seg
		seg.position = Vector2(0,0)
		seg.front = last_seg
		if last_seg:
			last_seg.back = seg
		last_seg = seg
		add_child(seg)
	phases[0].activate()

func _on_phase_timer_timeout(): # switch phase
	if NetworkState.is_server():
		phase_change.rpc()
		

@rpc ("call_local", "authority")
func phase_change():
	phases[current_phase].deactivate()
	current_phase = (current_phase + 1) % len(phases)
	phases[current_phase].activate()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if front_seg:
		$vis.position = front_seg.position
		front_seg.position += velocity * delta
