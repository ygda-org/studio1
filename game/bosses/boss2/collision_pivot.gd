extends Area2D

func die():
	if NetworkState.is_server():
		get_parent().die.rpc()
