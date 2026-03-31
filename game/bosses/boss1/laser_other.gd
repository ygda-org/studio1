extends Node2D

var rotation_speed = 30
var dmg = 10


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$RayCast2D.rotation_speed = rotation_speed
	$RayCast2D.dmg = dmg
