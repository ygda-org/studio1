extends BaseState

const RETURN_TO_CENTER_SPEED = 100
const PROJECTILE_SPEED = 150
const PROJECTILE_DMG = 10
@onready var projectile_position = states.get_parent().get_parent().get_node("ProjectilePosition").global_position

func _ready():
	get_parent().global_position = projectile_position

func _process(_delta):
	if not active:
		return
	if (states.get_parent().position - projectile_position).length() > 5 and NetworkState.is_server():
		states.get_parent().velocity = RETURN_TO_CENTER_SPEED * global_position.direction_to(projectile_position)
	elif (states.get_parent().position - projectile_position).length() <= 5:
		states.get_parent().velocity = Vector2.ZERO
	
	if active and $BulletCD.is_stopped() and NetworkState.is_server():
		$BulletCD.start()
		var target = GameState.players.pick_random()
		var velocity = get_parent().global_position.direction_to(target.global_position) * PROJECTILE_SPEED
		shoot.rpc(target, velocity)

@rpc ("authority", "call_local")
func shoot(target, velocity):
	if not target:
		return
	var projectile = load("res://bosses/boss1/bullet.tscn").instantiate()
	projectile.velocity = velocity
	projectile.dmg = PROJECTILE_DMG
	projectile.global_position = global_position
	states.get_parent().get_parent().add_child(projectile)
