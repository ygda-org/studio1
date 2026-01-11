extends Node2D

@export var health = 0

func hit(dmg):
	health -= dmg
	if health <= 0:
		get_parent().die()
