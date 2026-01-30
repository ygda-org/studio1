extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	NetworkState.player_list_updated.connect(update_player_list)

func update_player_list():
	for child in %PlayerList.get_children():
		child.queue_free()
	
	var is_everybody_ready: bool = true
	
	for player_info: PlayerInfo in NetworkState.players.values():
		var label: Label = Label.new()
		if not player_info.is_ready:
			is_everybody_ready = false
		label.text = player_info.player_name + " | " + ("Ready!" if player_info.is_ready else "Not Ready")
		%PlayerList.add_child(label)
	
	%Begin.disabled = not is_everybody_ready or %LevelSelect.selected == -1
	
	
func _on_level_select_item_selected(_index: int) -> void:
	update_player_list()

func _on_check_button_toggled(toggled_on: bool) -> void:
	set_ready.rpc(toggled_on)

@rpc("any_peer", "call_local", "reliable")
func set_ready(is_ready: bool):
	NetworkState.players[multiplayer.get_remote_sender_id()].is_ready = is_ready
	update_player_list()

func _on_begin_pressed() -> void:
	start_game.rpc_id(1, %LevelSelect.selected)


@rpc("any_peer", "call_remote", "reliable")
func start_game(level_id):
	if not multiplayer.is_server():
		GameState.error("A player tried to start the game locally?")
		return
		
	for player: PlayerInfo in NetworkState.players.values(): # Return early if not all players are ready
		if not player.is_ready:
			return
			
	var path: String
	match level_id:
		1:
			path = "res://bosses/playground_level.tscn"
		2:
			path = "res://bosses/boss1/level.tscn"
		3:
			path = "res://bosses/boss2/level.tscn"
		4:
			path = "res://bosses/boss3/level.tscn"
		_:
			return
	
	NetworkState.server_switch_scene(path)
