extends BaseState

const SPEED = 100

@export var bounce_shape: Shape2D

@onready var extras = $Extras

var bounce

var dir_alternate = 1

func activate():
	super()
	$StartTimer.start()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not active:
		return
	if bounce:
		bounce.rotation = boss.segments[0].rotation
		extras.rotation = boss.segments[0].rotation

func _on_start_timer_timeout():
	bounce = load("uid://boh7edtc42xte").instantiate()
	var bounce_coll = CollisionShape2D.new()
	bounce_coll.shape = bounce_shape
	bounce.add_child(bounce_coll)
	add_child(bounce)
	boss.get_node("States").queue_free()
	boss.get_node("States2").queue_free() # to clear slam clones
	$BounceQueueFreeTimer.start()
	$ProjectileTimer.start()
	$AnimationPlayer.play("transition")
	for i in range(20):
		var copy
		for n in boss.get_node("Polygons").get_children():
			copy = n.duplicate()
			copy.position = n.position + Vector2(30.0 * (1.0+i/2.0) * (1.0 if i % 2 == 0 else -1.0) - 12, -8.0)
			copy.z_index = -1
			copy.modulate = Color(0.231, 0.231, 0.231, 1.0)
			extras.add_child(copy)



func _on_animation_player_animation_finished(anim_name):
	if NetworkState.is_server() and anim_name == 'transition':
		boss.die.rpc()
		queue_free()


func _on_bounce_queue_free_timer_timeout():
	bounce.queue_free()


func _on_projectile_timer_timeout():
	if NetworkState.is_server():
		$ProjectileTimer.start()
		shoot()

func shoot():
	var proj = load("uid://12g1q21pqau4").instantiate()
	proj.name = "Sickle" + str(GameState.elapsed_time)
	boss.get_parent().add_child(proj)
	proj.initial_setup.rpc(boss.global_position, dir_alternate)
	dir_alternate *= -1
