extends Node2D

var velocity
var dmg

func _process(delta):
	position += velocity*delta


func _on_hitbox_body_entered(body):
	var damageable = body.find_child("EnemyDamageable")
	if damageable:
		damageable.hit(dmg)
		queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
