extends Node2D

var velocity = Vector2(0,0)
const SIDE_VELOCITY = 110
const FALL_ACCELERATION = 500
const MAX_FALL_SPEED = 4000 # honestly not necessary lol

@onready var bursts = $Bursts.get_children()
var velocitiesX = []
var velocitiesY = []

func _ready():
	$Bursts.visible = false
	for burst in bursts:
		burst.monitoring = false

func _process(delta):
	if not $Preburst.is_stopped():
		position += velocity * delta
	else:
		for i in range(len(bursts)):
			var burst = bursts[i]
			velocitiesY[i] += FALL_ACCELERATION * delta
			if velocitiesY[i] > MAX_FALL_SPEED:
				velocitiesY[i] = MAX_FALL_SPEED
			burst.position.x += velocitiesX[i] * delta
			burst.position.y += velocitiesY[i] * delta


func _on_preburst_timeout():
	$Riser.queue_free()
	$Bursts.visible = true
	for i in range(len(bursts)):
		var burst = bursts[i]
		velocitiesY.append(0)
		if i%2 == 0:
			velocitiesX.append(int(i/2) * SIDE_VELOCITY)
		else:
			velocitiesX.append(int(i/2) * SIDE_VELOCITY * -1)
		burst.monitoring = true
		
