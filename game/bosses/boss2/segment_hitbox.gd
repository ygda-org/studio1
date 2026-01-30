extends Area2D

func hit(dmg):
	get_parent().get_parent().get_node("Health").hit(dmg)
