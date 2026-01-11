extends Node

const MAX_CLIENTS: int = 4
const TIMEOUT_DELAY: float = 5

enum State {
	lobby,
	game
}

signal player_list_updated()

var room_password: String = "placeholder_password"
var players: Dictionary[int, PlayerInfo] = {} # ID -> Player info

func exit_session(message: String, is_error: bool):
	if is_error:
		GameState.critical(message)
	else:
		GameState.log(message)
	
	multiplayer.set_multiplayer_peer(null)
	get_tree().change_scene_to_file("res://main/main.tscn")

func is_server():
	return multiplayer.is_server()

func _player_joined(id: int):
	if is_server():
		GameState.log("Player joined with id: %s" % id)
		
		await get_tree().create_timer(TIMEOUT_DELAY).timeout
		
		if not players.has(id) and id in multiplayer.get_peers():
			multiplayer.multiplayer_peer.disconnect_peer(id)
			GameState.log("Player with id %s timed out, didn't send password in time" % id)
	
func _player_left(id: int):
	if is_server():
		GameState.log("Player left with id: %s" % id)
	
	if players.has(id):
		players.erase(id)

func _connection_failed():
	exit_session("Failed to connect", true)
	
func start_server(port: int, password: String):
	room_password = password
	var peer = ENetMultiplayerPeer.new()
	var err: Error = peer.create_server(port, MAX_CLIENTS)
	if err != OK:
		GameState.critical("Failed to start server!")
		return	

	multiplayer.set_multiplayer_peer(peer)
	multiplayer.allow_object_decoding = true
	
func start_client(address: String, port: int, username: String,password: String):
	var peer = ENetMultiplayerPeer.new()
	var err: Error = peer.create_client(address, port)
	if err != OK:
		GameState.critical("Failed to start client!")
		return 
	
	multiplayer.set_multiplayer_peer(peer)
	multiplayer.allow_object_decoding = true
	var player_info: PlayerInfo = PlayerInfo.new()
	player_info.player_name = username
	
	await multiplayer.connected_to_server 
	
	send_credentials.rpc_id(1, player_info, password)

@rpc("any_peer","call_remote", "reliable")
func send_credentials(player_info: PlayerInfo, password: String):
	var remote_id: int = multiplayer.get_remote_sender_id()
	
	if not is_server():
		GameState.error("Player with id %s tried to register on another client!" % remote_id)
		return
	
	if password != room_password:
		multiplayer.multiplayer_peer.disconnect_peer(remote_id)
		GameState.log("Client with id %s tried connecting with an incorrect password" % remote_id)
	else:
		GameState.log("Player with id %s registered successfully" % remote_id)
		register_player.rpc(player_info, remote_id)
		
	
@rpc("authority", "call_local", "reliable")
func register_player(player_info: PlayerInfo, id: int):
	players[id] = player_info
	player_list_updated.emit()


func _ready() -> void:
	multiplayer.peer_connected.connect(_player_joined)
	multiplayer.peer_disconnected.connect(_player_left)
	multiplayer.connection_failed.connect(_connection_failed)
