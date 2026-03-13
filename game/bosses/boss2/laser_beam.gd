extends Node2D

func _process(_delta):
	if $RayCast2D.is_colliding():
		$GPUParticles2D.visible = true
		$GPUParticles2D.global_position = $RayCast2D.get_collision_point()
	else:
		$GPUParticles2D.visible = false

@rpc ("call_local", "authority")
func suicide():
	call_deferred("queue_free")
