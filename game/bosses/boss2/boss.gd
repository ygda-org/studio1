extends Node2D

var velocity = Vector2(0,0)

@onready var phases = $States.get_children()
var current_phase = 0
var current_tick = 0

const SPEED = 200
const WIGGLE_CONSTANT = 0.004

const PHASE_2_HEALTH = 40

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
			n.rotation += delta*sin(float(current_tick)/10+start)
		elif stage == 2 and $States2/Hanging.active:
			pass
		else:
			n.rotation = velocity.length() * WIGGLE_CONSTANT*delta*sin(float(current_tick)/10+start)
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
		velocity.x = cos(segments[0].rotation - PI/2) * 450
		velocity.y = sin(segments[0].rotation - PI/2) * 450
		current_phase = -1
		if NetworkState.is_server():
			phase_change.rpc()
		$PhaseTimer.stop()
	elif stage == 2:
		$CollisionPivot/Health.health = 100000
		stage = 3
		get_parent().phase3.rpc()
		for n in phases:
			n.deactivate()
		$States3/Transition.activate()
	elif stage == 3:
		stage = 4
		get_parent().phase4()

func _on_head_anim_timeout():
	$Polygons/Head.texture_offset.x = int($Polygons/Head.texture_offset.x + 38) % (38*4)
