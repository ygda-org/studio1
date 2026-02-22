extends BaseState

signal change_phase

const RETURN_TO_CENTER_SPEED = 100
const PROJECTILE_SPEED = 150
const PROJECTILE_DMG = 10
@onready var projectile_position = states.get_parent().get_parent().get_node("ProjectilePosition").global_position

func _ready():
	get_parent().global_position = projectile_position
	connect("activating", activation)
	
func activation():
	$PhaseTimer.wait_time = randf_range(5, 10)
	$PhaseTimer.start()
	
func _on_phase_timer_timeout() -> void:
	change_phase.emit()

func _process(_delta):
	if not active:
		return
	
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
