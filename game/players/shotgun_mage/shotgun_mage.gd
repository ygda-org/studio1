extends Node2D

const DAMAGE = 10 # no idea what numbers will be good

const NORMAL_RECOIL = 250
const BIG_RECOIL = 400
const BOMB_VELOCITY = 400

var can_shoot = true
var can_shoot_big = true

func _ready():
	GameState.shotgun_mage = self
	get_parent().get_node("Sprite2D").visible = false # just to remove base player sprite

func _process(_delta): # purely visual stuff
	if get_parent().is_on_floor():
		if get_parent().velocity.x > 0:
			scale.x = 1
		elif get_parent().velocity.x < 0:
			scale.x = -1

func process_input(input):
	if input.mouse_pos.x > global_position.x:
		$ShotgunHelper.scale.x = 1
		$ShotgunHelper.look_at(input.mouse_pos)
	else:
		$ShotgunHelper.scale.x = -1
		$ShotgunHelper.look_at(input.mouse_pos) 
		$ShotgunHelper.rotation += PI
	if input.left_click and can_shoot:
		shoot()
		recoil(NORMAL_RECOIL, input.mouse_pos)
	if input.right_click and can_shoot_big:
		shoot_big(input.mouse_pos)
		recoil(BIG_RECOIL, input.mouse_pos)

func recoil(weight, mouse_pos):
	$GravityNullDur.start()
	get_parent().gravity_locked = true
	get_parent().velocity += weight*(mouse_pos-global_position).normalized()*Vector2(-1,-1)

func shoot():
	can_shoot = false
	$MainCD.start()
	$ShotgunHelper/Barrel/Tracers.visible = true
	$TracerDur.start()
	for ray_cast in $ShotgunHelper/Barrel.get_children():
		if ray_cast is RayCast2D and ray_cast.is_colliding():
			var damageable = ray_cast.get_collider().find_child("PlayerDamageable")
			if damageable:
				damageable.hit(DAMAGE)

func shoot_big(mouse_pos):
	can_shoot_big = false
	$BigBombCD.start()
	var bomb = load("res://players/shotgun_mage/big_bomb.tscn").instantiate()
	bomb.set_velocity((mouse_pos-global_position).normalized()*BOMB_VELOCITY)
	bomb.top_level = true
	add_child(bomb)
	bomb.global_position = $ShotgunHelper/Barrel.global_position

func _on_main_cd_timeout():
	can_shoot = true

func _on_gravity_null_dur_timeout():
	get_parent().gravity_locked = false

func _on_big_bomb_cd_timeout():
	can_shoot_big = true


func _on_tracer_dur_timeout() -> void:
	$ShotgunHelper/Barrel/Tracers.visible = false
