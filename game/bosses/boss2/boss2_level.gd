extends "res://bosses/level.gd"

func start_game():
	super()
	var boss = load("uid://bmq26vykccdr8").instantiate()
	boss.name = "Boss"
	boss.position = Vector2(0,0)
	add_child(boss)

@rpc ("call_local", "authority")
func phase2():
	$CirclePath.call_deferred("queue_free")
	$TileMapLayer2.visible = true
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
