class_name WormSegment
extends Node2D

var front
var back

@onready var end = $End
@onready var start = $Start

func _process(_delta):
	if front:
		global_position = global_position.lerp(front.global_position, 0.03) #+ (start.global_position - global_position)#- (front.end.global_position - start.global_position)
		var pos_diff = front.end.global_position-global_position
		rotation = atan(pos_diff.y/pos_diff.x) + (PI if front.end.global_position.x < start.global_position.x else 0.0) #look_at(front.end.global_position)
	else:
		rotation = atan(get_parent().velocity.y/get_parent().velocity.x) + (PI if get_parent().velocity.x > 0 else 0.0)
