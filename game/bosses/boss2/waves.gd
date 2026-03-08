extends BaseState

const WAVE_SPEED = 120
const WAVE = preload("uid://cc1jd47ign5tn")
var dir = 0
var alternation = 1

func activate():
	super()
	alternation = -1
	#position = Vector2(400, 0)
	boss.velocity = Vector2.ZERO
	if NetworkState.is_server():
		dir = randi_range(0,1)*2-1
		if dir == -1:
			$AnimationPlayer.play("StartRight")
		else:
			$AnimationPlayer.play("StartLeft")
		set_dir.rpc(dir)
	$CD.start()

@rpc ("call_remote", "authority")
func set_dir(d):
	dir = d
	if dir == -1:
		$AnimationPlayer.play("StartRight")
	else:
		$AnimationPlayer.play("StartLeft")

func _on_cd_timeout():
	if alternation == 1:
		$AnimationPlayer.play("Up")
	elif alternation == -1:
		$AnimationPlayer.play("Down")
	var wav = WAVE.instantiate()
	wav.rotation = 0.0 if alternation == 1 else PI
	wav.position.x = boss.position.x
	wav.global_position.y = boss.get_parent().get_node("ShockwaveMidpoint").global_position.y
	wav.position.y += 125 * alternation
	wav.wave_speed = WAVE_SPEED
	alternation = 1 if alternation == -1 else -1
	if NetworkState.is_server():
		wav.name = "Shockwave" + str(GameState.elapsed_time)
		boss.get_parent().add_child(wav)
		wav.set_dir.rpc(dir, wav.rotation)
	if active:
		$CD.start()
