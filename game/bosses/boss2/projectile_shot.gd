extends Node2D

var velocity = Vector2(0,0)
const PROJECTILE = preload("uid://d05mwq2yktdsv")

# Called when the node enters the scene tree for the first time.
func _ready():
	position += Vector2(0, -40)
	velocity = GameState.shot_velocity
	var b1 = PROJECTILE.instantiate()
	var b2 = PROJECTILE.instantiate()
	var b3 = PROJECTILE.instantiate()
	b1.name = "b1"
	b2.name = "b2"
	b3.name = "b3"
	b1.velocity = velocity
	b2.velocity = velocity.rotated(PI/6)
	b3.velocity = velocity.rotated(-PI/6)
	add_child(b1)
	add_child(b2)
	add_child(b3)


func set_vars(v):
	velocity = v


func _on_despawn_timer_timeout():
	queue_free()
