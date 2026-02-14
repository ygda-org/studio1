extends Area2D

var velocity = Vector2(0.1,0.1)
var dmg

func _process(delta):
	if not velocity:
		queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func _on_body_entered(body):
	var damageable = body.find_child("EnemyDamageable")
	if damageable:
		damageable.hit(dmg)
		queue_free()

@rpc ("call_local", "reliable")
func set_vars(v):
	velocity = v
