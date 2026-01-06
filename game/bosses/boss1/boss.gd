extends Area2D

const CONTACT_DAMAGE = 10

@onready var phases = $States.get_children()
var current_phase = 0

var velocity = Vector2.ZERO

func _ready():
	phases[0].activate()
	
func _process(delta):
	position = position + (velocity * delta)

func _on_phase_timer_timeout(): # switch phase
	phases[current_phase].deactivate()
	current_phase = (current_phase + 1) % len(phases)
	phases[current_phase].activate()

func die():
	queue_free()


func _on_body_entered(body):
	var damageable = body.find_child("EnemyDamageable")
	if damageable:
		damageable.hit(CONTACT_DAMAGE)
