extends CharacterBody2D

@onready var phases = $States.get_children()
var current_phase = 0

func _ready():
	phases[0].activate()
	
func _physics_process(delta):
	move_and_slide()

func _on_phase_timer_timeout(): # switch phase
	phases[current_phase].deactivate()
	current_phase = (current_phase + 1) % len(phases)
	phases[current_phase].activate()

func die():
	queue_free()
