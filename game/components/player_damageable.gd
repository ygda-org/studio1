extends Node2D

func hit(dmg):
	if NetworkState.is_server():
		get_parent().hit.rpc(dmg)
