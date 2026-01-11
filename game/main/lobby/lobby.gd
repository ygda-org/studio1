extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	NetworkState.player_list_updated.connect(update_player_list)

func update_player_list():
	for child in %PlayerList.get_children():
		child.queue_free()
		
	for player_info: PlayerInfo in NetworkState.players.values():
		var label: Label = Label.new()
		label.text = player_info.player_name + " | " + ("Ready!" if player_info.is_ready else "Not Ready")
		%PlayerList.add_child(label)
	


func _on_check_button_toggled(toggled_on: bool) -> void:
	set_ready.rpc(toggled_on)

@rpc("any_peer", "call_local", "reliable")
func set_ready(is_ready: bool):
	NetworkState.players[multiplayer.get_remote_sender_id()].is_ready = is_ready
	update_player_list()
