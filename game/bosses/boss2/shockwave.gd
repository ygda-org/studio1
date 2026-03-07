extends Area2D

var wave_speed = 100
var direction = 1

var velocity = Vector2()

func _process(_delta):
	velocity.x = direction * wave_speed

@rpc ("call_local")
func set_dir(d, r):
	direction = d
	rotation = r
