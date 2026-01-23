extends Node2D

signal ninja_attempt_swap

func _ready():
	GameState.ninja_mage = self

func _process(delta):
	if Input.is_action_just_pressed("right_click"):
		ninja_attempt_swap.emit()
