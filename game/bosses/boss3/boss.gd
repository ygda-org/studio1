extends Node2D

@rpc ("authority", "call_local")
func play_intro():
	$AnimationPlayer.play("Intro")
