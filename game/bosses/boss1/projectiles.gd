extends BaseState

const RETURN_TO_CENTER_SPEED = 100
const PROJECTILE_SPEED = 150
const PROJECTILE_DMG = 10
@onready var projectile_position = states.get_parent().get_parent().get_node("ProjectilePosition").global_position

func _process(delta):
	if not active:
		return
	if (states.get_parent().position - projectile_position).length() > 5:
		states.get_parent().velocity = RETURN_TO_CENTER_SPEED * global_position.direction_to(projectile_position)
	else:
		states.get_parent().velocity = Vector2.ZERO
	
	if active and $BulletCD.is_stopped():
		$BulletCD.start()
		shoot()

func shoot():
	var target = GameState.players.pick_random()
	var projectile = load("res://bosses/boss1/bullet.tscn").instantiate()
	projectile.velocity = projectile.global_position.direction_to(target.get_node("BasePlayer").global_position) * PROJECTILE_SPEED
	projectile.dmg = PROJECTILE_DMG
	projectile.global_position = global_position
	states.get_parent().get_parent().add_child(projectile)
