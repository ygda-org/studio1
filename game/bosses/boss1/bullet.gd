extends Node2D

var velocity
var dmg

func _ready():
	position = get_parent().get_node("Boss").position

func _process(delta):
	if not velocity:
		queue_free()
	position += velocity*delta


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func _on_body_entered(body):
	var damageable = body.find_child("EnemyDamageable")
	if damageable:
		damageable.hit(dmg)
		queue_free()
