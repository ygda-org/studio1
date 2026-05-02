extends "res://bosses/level.gd"

func start_game():
	play_intro.rpc()
	super()

@rpc ("authority", "call_local")
func play_intro():
	$AnimationPlayer.play("Intro")

@rpc ("call_local", "authority")
func phase1():
	$TileMapLayer0.queue_free()
	$TileMapLayer.collision_enabled = true
	$TileMapLayer.visible = true
	var boss = load("uid://bmq26vykccdr8").instantiate()
	boss.name = "Boss"
	boss.position = Vector2(0,0)
	add_child(boss)


@rpc ("call_local", "authority")
func phase2():
	$CirclePath.call_deferred("queue_free")
	$TileMapLayer2.visible = true
	$TileMapLayer2.collision_enabled = true
	$AnimationPlayer.play("PhaseTransition")
	$TileMapLayer.queue_free()

@rpc ("call_local", "authority")
func phase3():
	$TileMapLayer3.collision_enabled = true
	$TileMapLayer2.queue_free()
	$AnimationPlayer.play("PhaseTransition2")
	$TileMapLayer3.visible = true

@rpc ("call_local", "authority")
func phase4():
	#$TileMapLayer5.collision_enabled = true
	$TileMapLayer3.queue_free()
	$Phase4Pit.visible = true
	$Phase4Light.visible = true
	$TileMapLayer5.visible = true


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Intro" and NetworkState.is_server():
		phase1.rpc()
