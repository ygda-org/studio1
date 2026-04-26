extends Area2D

@export var dmg = 20
@export var bounce_strength = -500


func _on_body_entered(body):
	var damageable = body.find_child("EnemyDamageable")
	if damageable:
		damageable.hit(dmg)
		damageable.get_parent().get_parent().velocity = Vector2(0, bounce_strength).rotated(rotation) + Vector2(0, -50)
