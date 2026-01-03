extends Sprite2D

var direction

func set_vector(dir):
	direction = dir

func _on_area_2d_body_entered(body):
	var gravity_change = body.find_child("GravityChange")
	if gravity_change:
		gravity_change.set_gravity(direction)


func _on_duration_timeout():
	queue_free()
