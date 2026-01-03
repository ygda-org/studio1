extends Node2D

var gravity: Vector2

func _process(delta):
	if gravity:
		#get_parent().velocity = gravity 
		get_parent().movement_locked = true
		get_parent().velocity += gravity * delta

func set_gravity(g):
	gravity = g*300
	$Duration.start()

func _on_duration_timeout():
	get_parent().movement_locked = false
	gravity = Vector2.ZERO
