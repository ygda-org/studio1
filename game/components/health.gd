extends Node2D

@export var max_health = 0 # only for things that can heal or need it
@export var health = 0

@rpc ("call_local", "authority")
func hit(dmg):
	health -= dmg
	if health <= 0:
		get_parent().die()
