extends Node2D

var velocity = Vector2(0,0)

@onready var phases = $States.get_children()
var current_phase = 0
var current_tick = 0

const SPEED = 200
const WIGGLE = 1

const PHASE_2_HEALTH = 400

var segments = []
var base_rotations = [null]
var head_anim_frame = 0
var skip_center = false

var stage = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	position = Vector2(100,0)
	phases[0].activate()
	var n = $Skeleton2D/Bone2D
	while n.get_children():
		base_rotations.append(0)
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
	$VisibleOnScreenNotifier2D.global_position = segments[0].global_position
	var n = $Skeleton2D/Bone2D
	var start = 1
	while n.get_children():
		n = n.get_children()[0]
		if stage == 1 and $States/Circle.active:
			n.rotation += WIGGLE*delta*sin(float(current_tick)/10+start)
		else:
			n.rotation = WIGGLE*delta*sin(float(current_tick)/10+start)
		start += 1
	$CollisionPivot.rotation = segments[0].rotation
	current_tick += 1
	
@rpc ("authority", "call_local")
func die():
	if stage == 1:
		$CollisionPivot/Health.health = PHASE_2_HEALTH
		stage = 2
		get_parent().phase2()
		for n in phases:
			n.deactivate()
		phases = $States2.get_children()
		current_phase = 0
		phase_change.rpc()
		$PhaseTimer.start()

func _on_head_anim_timeout():
	$Polygons/Head.texture_offset.x = int($Polygons/Head.texture_offset.x + 38) % (38*4)
