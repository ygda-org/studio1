extends Area2D

const CONTACT_DAMAGE = 10
@onready var phases = $States.get_children()
var current_phase = 0
var current_tick = 0
var phase = 1

var velocity = Vector2.ZERO

func _ready():
	position = get_parent().get_node("ProjectilePosition").position
	phases[0].activate()

@rpc ("call_local", "authority")
func phase_change():
	if phase <= 3:
		phases[current_phase].deactivate()
		current_phase = (current_phase + 1) % len(phases)
		phases[current_phase].activate()

func die():
	if phase < 2:
		phase += 1
		$Health.health = 150
	else:
		for phase in phases:
			phase.deactivate()

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
