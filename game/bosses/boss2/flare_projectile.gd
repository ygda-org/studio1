extends Node2D

var velocity = Vector2(0,0)
const SIDE_VELOCITY = 80
const FALL_ACCELERATION = 500
const MAX_FALL_SPEED = 4000 # honestly not necessary lol
var dmg = 6

@onready var bursts = $Bursts.get_children()
var velocitiesX = []
var velocitiesY = []

@rpc ("authority", "call_local")
func set_vars(v, p):
	velocity = v
	global_position = p

func _ready():
	$Bursts.visible = false
	$Riser.body_entered.connect(_area_2d_body_entered)
	for burst in bursts:
		burst.monitoring = false
		burst.body_entered.connect(_area_2d_body_entered)

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
			velocitiesX.append(int((i+2)/2) * SIDE_VELOCITY)
		else:
			velocitiesX.append(int((i+2)/2) * SIDE_VELOCITY * -1)
		burst.monitoring = true
		
func _area_2d_body_entered(body):
	var damageable = body.find_child("EnemyDamageable")
	if damageable:
		damageable.hit(dmg)
		#queue_free()


func _on_life_time_timeout():
	queue_free()
