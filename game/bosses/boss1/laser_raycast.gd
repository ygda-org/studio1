extends RayCast2D

# followed a gd quest tutorial for this

var rotation_speed = 30
var speed = 300
var is_casting := true
var dmg = 10

# Called when the node enters the scene tree for the first time.
func _physics_process(delta: float) -> void:
	if not is_casting:
		rotation_degrees += rotation_speed * delta
	if is_casting or speed < 0:
		target_position.x += speed * delta
	if target_position.x < 10:
		queue_free()
	var laser_end_position := target_position
	force_raycast_update()
	if is_colliding():
		is_casting = false
		laser_end_position = to_local(get_collision_point())
		var body = get_collider()
		var damageable = body.find_child("EnemyDamageable")
		if damageable:
			damageable.hit(dmg)
			queue_free()
	else:
		is_casting = true
	$Line2D.points[1] = laser_end_position
	
func _on_lifetime_timeout() -> void:
	speed *= -1
