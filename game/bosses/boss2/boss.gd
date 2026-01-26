extends Node2D

var velocity = Vector2(0,0)

@onready var phases = $States.get_children()
var current_phase = 0
var current_tick = 0

const SPEED = 200

var segments = []
var wiggle = 1
var head_anim_frame = 0
var skip_center = false

# Called when the node enters the scene tree for the first time.
func _ready():
	position = Vector2(100,0)
	phases[0].activate()
	var n = $Skeleton2D/Bone2D
	while n.get_children():
		segments.append(n)
		n = n.get_children()[0]

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
	$VisibleOnScreenNotifier2D.global_position = segments[-1].global_position
	var n = $Skeleton2D/Bone2D
	var start = 1
	while n.get_children():
		n = n.get_children()[0]
		n.rotation += PI/4 * wiggle * start * delta
		start *= -1
	#if front_seg:
	#	$vis.position = front_seg.position
	#	front_seg.position += velocity * delta


func _on_wiggle_dur_timeout():
	if skip_center:
		skip_center = false
	else:
		wiggle = wiggle * -1
		skip_center = true


func _on_head_anim_timeout():
	$Polygons/Head.texture_offset.x = int($Polygons/Head.texture_offset.x + 38) % (38*4)
