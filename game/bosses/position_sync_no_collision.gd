extends Node2D

@onready var parent = get_parent()
var latest_server_state: Dictionary = {}
var state_buffer: Array[ClientState]
const BUFFER_SIZE = 1024
const MAXIMUM_RECONCILE_DISTANCE = 40

func _process(delta):
	if parent.velocity != null:
		parent.position += parent.velocity * delta
	if NetworkState.is_server():
		client_receive_state.rpc(parent.position, parent.velocity)
	else:
		reconcile_state(delta)

@rpc ("authority", "unreliable_ordered")
func client_receive_state(pos, v):
	latest_server_state = {'pos': pos, 'v': v}

func reconcile_state(delta: float):
	if latest_server_state == {}:
		return
	var difference = latest_server_state['pos'].distance_to(parent.position)
	if difference > MAXIMUM_RECONCILE_DISTANCE:
		#GameState.log("Syncing %s position desync!" % parent)
		
		parent.position = parent.position.lerp(latest_server_state['pos'], 50 * delta)
		parent.velocity = latest_server_state['v']
	latest_server_state = {}
