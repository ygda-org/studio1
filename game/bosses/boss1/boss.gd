extends Area2D

signal next_phase

const CONTACT_DAMAGE = 10
@onready var attacks = $States.get_children()
var current_attack = randi_range(1, 2)
var current_tick = 0
var phase = 1
var attack = 0
var phase_change_queued = false

var velocity = Vector2.ZERO

func _ready():
	position = get_parent().get_node("ProjectilePosition").position
	attacks[current_attack].activate()

@rpc ("call_local", "authority")
func phase_change():
	if attack <= 3:
		attacks[current_attack].deactivate()
		if phase_change_queued:
			$Health.health = 150
			next_phase.emit()
		current_attack = randi_range(0, 2)
		$PhaseCooldown.start()
		
func _on_phase_cooldown_timeout() -> void:
	attacks[current_attack].activate()


func die():
	if phase < 2:
		phase_change_queued = true
		phase += 1
	else:
		for attack in attacks:
			attack.deactivate()

func _on_body_entered(body):
	var damageable = body.find_child("EnemyDamageable")
	if damageable:
		damageable.hit(CONTACT_DAMAGE)


func _on_projectiles_change_phase() -> void:
	if NetworkState.is_server():
		phase_change.rpc()

func _on_dashing_change_phase() -> void:
	if NetworkState.is_server():
		phase_change.rpc()

func _on_laser_change_phase() -> void:
	if NetworkState.is_server():
		phase_change.rpc()
