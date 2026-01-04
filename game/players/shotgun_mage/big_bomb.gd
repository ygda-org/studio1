extends CharacterBody2D

func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
