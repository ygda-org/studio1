extends CharacterBody2D

const SPEED = 100.0
const ACCELERATION = 1500.0
const DECELERATION = 0.3
const JUMP_VELOCITY = -340.0
const MAX_FALL_SPEED = 200
const AIR_CONTROL = 0.7
const AIR_FRICTION = 0.02

@export var acceleration_curve: Curve
@export var gravity_curve: Curve
@export var health_override: int

var can_jump
var movement_locked = false
var gravity_locked = false
var jump_input = false # for jump buffering

var mouse_position: Vector2 # for syncing up stuffs

func _ready():
	if health_override:
		$Health.health = health_override

func _physics_process(delta):
	mouse_position = get_global_mouse_position()
	if not movement_locked:
		movement(delta)

	move_and_slide()

func movement(delta):
	# gravity
	if not is_on_floor() and velocity.y < MAX_FALL_SPEED and not gravity_locked:
		velocity += get_gravity() * delta * gravity_curve.sample((JUMP_VELOCITY-velocity.y)/JUMP_VELOCITY if velocity.y < 0 and velocity.y > JUMP_VELOCITY else 1.0)

	# jump
	if is_on_floor():
		can_jump = true
	elif $CoyoteTime.is_stopped():
		$CoyoteTime.start()
	if Input.is_action_just_pressed("jump"):
		jump_input = true
		$JumpBuffer.start()
	if jump_input and can_jump:
		jump_input = false
		velocity.y = JUMP_VELOCITY

	# movement
	var direction = Input.get_axis("move_left", "move_right")
	if is_on_floor():
		if direction:
			velocity.x = clampf(velocity.x + acceleration_curve.sample(abs(velocity.x/SPEED)) * direction * ACCELERATION * delta, -SPEED, SPEED)
		else:
			velocity.x = lerp(velocity.x, 0.0, DECELERATION)
	else:
		if direction and (abs(velocity.x) < SPEED or direction * velocity.x<0):
			velocity.x += acceleration_curve.sample(abs(velocity.x/SPEED)) * direction * ACCELERATION * delta * AIR_CONTROL
		elif not direction:
			velocity.x = lerp(velocity.x, 0.0, AIR_FRICTION)

func die():
	movement_locked = true
	visible = false

func _on_coyote_time_timeout():
	can_jump = false


func _on_jump_buffer_timeout():
	jump_input = false
