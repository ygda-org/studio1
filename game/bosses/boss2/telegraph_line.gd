extends Sprite2D

var decay_rate = 2


func _process(delta):
	modulate = modulate - Color(0.0, 0.0, 0.0, decay_rate*delta)
	if modulate.a <= 0:
		queue_free()
