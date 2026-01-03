extends CharacterBody2D


const SPEED = 100.0
const ACCELERATION = 1500.0
const JUMP_VELOCITY = -300.0
const MAX_FALL_SPEED = 200

@export var acceleration_curve: Curve

var can_jump
var movement_locked

func _physics_process(delta):
	if not movement_locked:
		movement(delta)

	move_and_slide()

func movement(delta):
	# gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
		if velocity.y > MAX_FALL_SPEED:
			velocity.y = MAX_FALL_SPEED

	# jump
	if is_on_floor():
		can_jump = true
	elif $CoyoteTime.is_stopped():
		$CoyoteTime.start()
	if Input.is_action_just_pressed("jump") and can_jump:
		velocity.y = JUMP_VELOCITY

	# input dir
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = clampf(velocity.x + acceleration_curve.sample(abs(velocity.x/SPEED)) * direction * ACCELERATION * delta, -SPEED, SPEED)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func _on_coyote_time_timeout():
	can_jump = false
