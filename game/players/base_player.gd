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


var can_jump
var movement_locked = false
var gravity_locked = false
var jump_input = false # for jump buffering

var mouse_position: Vector2 # for syncing up stuffs

### Network Vars
const MAXIMUM_RECONCILE_DISTANCE: float = 60 # we can experiment with this value later

@export var net_id: int = -1

var latest_server_state: ClientState = null
const BUFFER_SIZE = 1024
var current_tick: int = 0
var input_buffer: Array[ClientInput] = []
var input_id: int = 0
var state_buffer: Array[ClientState] = []

### Server vars
var input_queue: Array[ClientInput] = []
var last_client_input: ClientInput = ClientInput.new()

### Other client vars
var prev_state: ClientState = ClientState.new()
var curr_state: ClientState = ClientState.new()

func _ready():
	input_buffer.resize(BUFFER_SIZE)
	state_buffer.resize(BUFFER_SIZE)
	if net_id == multiplayer.get_unique_id():
		set_role.rpc(NetworkState.this_player_role)

@rpc ("call_local", "any_peer")
func set_role(path):
	add_child(load(path).instantiate())

func get_current_state() -> ClientState:
	var state: ClientState = ClientState.new()
	state.position = position
	state.velocity = velocity
	state.tick = current_tick
	
	return state

func get_current_input() -> ClientInput:
	var input: ClientInput = ClientInput.new()
	input.is_jumping = Input.is_action_just_pressed("jump")
	@warning_ignore("narrowing_conversion")
	input.x_direction = Input.get_axis("move_left", "move_right")
	input.mouse_pos = get_global_mouse_position()
	input.left_click = Input.is_action_just_pressed("left_click")
	input.right_click = Input.is_action_just_pressed("right_click")
	input.tick = current_tick
	
	return input
	
func reconcile_state(delta: float):
	if latest_server_state == null or state_buffer[latest_server_state.tick % BUFFER_SIZE] == null:
		return
	
	var difference: float = latest_server_state.position.distance_to(state_buffer[latest_server_state.tick % BUFFER_SIZE].position)
	if difference > MAXIMUM_RECONCILE_DISTANCE:
		#GameState.log("Client %s position desync!" % multiplayer.get_unique_id())
		
		position = latest_server_state.position
		velocity = latest_server_state.velocity
				
		state_buffer[latest_server_state.tick % BUFFER_SIZE] = latest_server_state
		
		for tick in range(latest_server_state.tick, current_tick):
			var buffer_index: int = tick % BUFFER_SIZE
			movement(input_buffer[buffer_index], delta) # delta should be bout the same anyways
			state_buffer[buffer_index] = get_current_state()
	
	latest_server_state = null
	
func _physics_process(delta: float):
	var buffer_index: int = current_tick % BUFFER_SIZE
	
	#UI
	$HealthBar.value = $Health.health
	$HealthBar.max_value = $Health.max_health
	
	if NetworkState.is_server(): # The server
		buffer_index = -1 
		while not input_queue.is_empty():
			last_client_input = input_queue.pop_front()
			buffer_index = last_client_input.tick % BUFFER_SIZE
			movement(last_client_input, delta)
			state_buffer[buffer_index] = get_current_state()
		
		if buffer_index != -1:
			send_state_to_client_wrapper(state_buffer[buffer_index])
		else:
			movement(last_client_input, delta)
		
	elif multiplayer.get_unique_id() == net_id: # The player controlling this player node
		reconcile_state(delta)
			
		var input: ClientInput = get_current_input()
		input_buffer[buffer_index] = input
		movement(input, delta) # gonna add a bit of reconcile to movement
		
		state_buffer[buffer_index] = get_current_state()
		
		send_input_to_server_wrapper(input)
	else: # Another remote peer 
		# both positions are 0
		if latest_server_state:
			position = prev_state.position.lerp(latest_server_state.position, delta*5)#curr_state.position, delta*5)
			prev_state = latest_server_state
		
	current_tick += 1

func send_input_to_server_wrapper(input: ClientInput):
	send_input_to_server.rpc_id(1, input.x_direction, input.is_jumping, input.mouse_pos, input.left_click, input.right_click, input.tick)

@rpc("any_peer", "call_remote", "unreliable")
func send_input_to_server(x_direction, is_jumping, mouse_pos, left_click, right_click, tick):
	if not NetworkState.is_server():
		GameState.error("Client tried receiving input in send_input")
		return
	var input: ClientInput = ClientInput.new()
	input.x_direction = x_direction
	input.is_jumping = is_jumping
	input.left_click = left_click
	input.right_click = right_click
	input.mouse_pos = mouse_pos
	input.tick = tick
	input_queue.append(input)

func send_state_to_client_wrapper(state: ClientState):
	send_state_to_client.rpc(net_id, state.position, state.velocity, state.tick)

@rpc("authority", "call_remote", "unreliable")
func send_state_to_client(id, pos: Vector2, vel: Vector2, tick: int):
	var state: ClientState = ClientState.new()
	state.position = pos
	state.velocity = vel
	state.tick = tick
	if latest_server_state == null or tick > latest_server_state.tick:
		latest_server_state = state

func send_state_to_other_clients_wrapper(state: ClientState):
	for id in multiplayer.get_peers():
		if id == 1:
			continue
		
		send_state_to_other_clients.rpc_id(id, state.position, state.velocity)

@rpc("authority", "call_remote", "unreliable")
func send_state_to_other_clients(pos, vel):
	prev_state = curr_state
	curr_state = ClientState.new()
	curr_state.position = position
	curr_state.velocity = vel
	
@rpc ("authority", "call_local")
func jump():
	velocity.y = JUMP_VELOCITY

func movement(input: ClientInput, delta: float):
	if latest_server_state:
		position = position.lerp(latest_server_state.position, 5*delta*(position-latest_server_state.position).length())
	if movement_locked:
		return
	# gravity
	if not is_on_floor() and velocity.y < MAX_FALL_SPEED and not gravity_locked:
		velocity += get_gravity() * delta * gravity_curve.sample((JUMP_VELOCITY-velocity.y)/JUMP_VELOCITY if velocity.y < 0 and velocity.y > JUMP_VELOCITY else 1.0)

	# jump
	if is_on_floor():
		can_jump = true
	elif $CoyoteTime.is_stopped():
		$CoyoteTime.start()
	if input.is_jumping:
		jump_input = true
		$JumpBuffer.start()
	if jump_input and can_jump and NetworkState.is_server():
		jump_input = false
		jump.rpc()

	# movement
	var direction = input.x_direction
	if is_on_floor():
		if direction:
			velocity.x = clampf(velocity.x + acceleration_curve.sample(abs(velocity.x/SPEED)) * direction * ACCELERATION * delta, -SPEED, SPEED)
		else:
			velocity.x = lerp(velocity.x, 0.0, DECELERATION)
			if latest_server_state:
				position = position.lerp(latest_server_state.position, delta*10)
	else:
		if direction and (abs(velocity.x) < SPEED or direction * velocity.x<0):
			velocity.x += acceleration_curve.sample(abs(velocity.x/SPEED)) * direction * ACCELERATION * delta * AIR_CONTROL
		elif not direction:
			velocity.x = lerp(velocity.x, 0.0, AIR_FRICTION)
	
	# send input to specific class handlers
	var role
	for node in get_children():
		if node.name == "ShotgunMage" or node.name == "NinjaMage" or node.name == "GravityMage":
			role = node
			break
	if role:
		role.process_input(input)
	
	move_and_slide()

func die():
	movement_locked = true
	visible = false

func _on_coyote_time_timeout():
	can_jump = false


func _on_jump_buffer_timeout():
	jump_input = false
