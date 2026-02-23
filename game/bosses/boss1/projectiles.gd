extends BaseState

signal change_phase

const RETURN_TO_CENTER_SPEED = 100
const PROJECTILE_SPEED = 150
const PROJECTILE_DMG = 10
var attack
var double
@onready var projectile_position = states.get_parent().get_parent().get_node("ProjectilePosition").global_position

enum Attacks {
	BULLETS,
	GRAVITY_BULLETS
}

func _ready():
	get_parent().global_position = projectile_position
	connect("activating", activation)
	
func activation():
	$PhaseTimer.wait_time = randf_range(5, 10)
	$PhaseTimer.start()
	$BulletCD.start()
	attack = Attacks.values().pick_random()
	
func _on_phase_timer_timeout() -> void:
	change_phase.emit()

@rpc ("authority", "call_local")
func shoot(target, velocity, gravity_affected):
	if not target:
		return
	var projectile = load("res://bosses/boss1/bullet.tscn").instantiate()
	projectile.velocity = velocity
	projectile.dmg = PROJECTILE_DMG
	projectile.global_position = global_position
	projectile.gravity_affected = gravity_affected
	states.get_parent().get_parent().add_child(projectile)


func _on_bullet_cd_timeout() -> void:
	if not active:
		return
	
	if active and NetworkState.is_server():
		$BulletCD.start()
		var target = GameState.players.pick_random()
		double = abs(global_position.x) < 5
		if attack == Attacks.GRAVITY_BULLETS:
			var velocity = get_parent().global_position.direction_to(target.global_position) * PROJECTILE_SPEED + Vector2(randf_range(-20, 20), -100)
			shoot.rpc(target, velocity, true)
			if double:
				shoot.rpc(target, Vector2(velocity.x * -1, velocity.y), true)
		else:
			var velocity = get_parent().global_position.direction_to(target.global_position) * PROJECTILE_SPEED + Vector2(randf_range(-10, 10), randf_range(-10, 10))
			shoot.rpc(target, velocity, false)
			if double:
				shoot.rpc(target, Vector2(velocity.x * -1, velocity.y), false)
