extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var env_port: String = OS.get_environment("GAME_PORT")
	var env_password: String = OS.get_environment("GAME_PASSWORD")
	
	if env_port + env_password != "":
		NetworkState.start_server(int(env_port), env_password)
	

func _on_client_connect_pressed() -> void:
	NetworkState.start_client(%ClientAddress.text, int(%ClientPort.text), %ClientUsername.text, %ClientPassword.text)
	get_tree().change_scene_to_file("res://main/lobby/lobby.tscn")
	
func _on_server_connect_pressed() -> void:
	NetworkState.start_server(int(%ServerPort.text), %ServerPassword.text)
	get_tree().change_scene_to_file("res://main/lobby/lobby.tscn")
