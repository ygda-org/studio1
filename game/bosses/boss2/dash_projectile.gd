extends Area2D


var velocity = Vector2(0.1,0.1)
var dmg = 10

func _on_visible_on_screen_notifier_2d_screen_exited():
	call_deferred("queue_free")


func _on_body_entered(body):
	var damageable = body.find_child("EnemyDamageable")
	if damageable:
		damageable.hit(dmg)
		queue_free()

@rpc ("call_local")
func var_init(p, v, r):
	global_position = p
	velocity = v
	rotation = r
