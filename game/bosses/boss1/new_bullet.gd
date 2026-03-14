extends RigidBody2D

# apparently i shouldnt have removed the physics sync thing
# sounds like a problem for future me oops

var dmg
var gravity_affected
var velocity

func _ready():
	position = get_parent().get_node("Boss").position

func _physics_process(delta):
	if velocity:
		if gravity_affected:
			velocity.y += 4
			var collision_info = move_and_collide(velocity * delta)
			if collision_info:
				if not collision_info.get_collider().find_child("EnemyDamageable"):
						velocity = velocity.bounce(collision_info.get_normal())
						velocity *= 0.7
						if velocity.length() < 20:
							queue_free()
		else:
			move_and_collide(velocity * delta)
	else:
		queue_free()
	if velocity != null:
		position += velocity * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	var damageable = body.find_child("EnemyDamageable")
	if damageable:
		damageable.hit(dmg)
		queue_free()
	if not gravity_affected:
		queue_free()
