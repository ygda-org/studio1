class_name Level
extends Node2D

const BASE_PLAYER = preload("uid://gmr2mrr3v55v")

signal has_loaded()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	has_loaded.emit(scene_file_path)
	
	if not NetworkState.is_server():
		client_loaded_in.rpc_id(1)

@rpc("any_peer", "call_remote", "reliable")
func client_loaded_in():
	if not NetworkState.is_server():
		GameState.error("Client tried to run logic in client_loaded_in")
		return
	
	NetworkState.players[multiplayer.get_remote_sender_id()].has_loaded_in = true
	
	if NetworkState.are_all_players_loaded():
		start_game()
		

func start_game():
	for player: PlayerInfo in NetworkState.players.values():
		var new_player = BASE_PLAYER.instantiate()
		new_player.net_id = player.id
		add_child(new_player)
			
func _process(_delta: float) -> void:
	if not NetworkState.is_server():
		%Ping.text = str(NetworkState.peer.get_peer(1).get_statistic(ENetPacketPeer.PEER_ROUND_TRIP_TIME))
