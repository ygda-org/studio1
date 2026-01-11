extends Node2D

const DAMAGE = 10 # no idea what numbers will be good

const NORMAL_RECOIL = 250
const BIG_RECOIL = 400
const BOMB_VELOCITY = 400

var can_shoot = true
var can_shoot_big = true

func _ready():
	GameState.shotgun_mage = self

func _process(delta):
	if get_global_mouse_position().x > global_position.x:
		$ShotgunHelper.scale.x = 1
		$ShotgunHelper.look_at(get_global_mouse_position())
	else:
		$ShotgunHelper.scale.x = -1
		$ShotgunHelper.look_at(get_global_mouse_position()) 
		$ShotgunHelper.rotation += PI
	if Input.is_action_just_pressed("left_click") and can_shoot:
		shoot()
		recoil(NORMAL_RECOIL)
	if Input.is_action_just_pressed("right_click") and can_shoot_big:
		shoot_big()
		recoil(BIG_RECOIL)

func recoil(weight):
	$GravityNullDur.start()
	get_parent().gravity_locked = true
	get_parent().velocity += weight*(get_global_mouse_position()-global_position).normalized()*Vector2(-1,-1)

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

func shoot_big():
	can_shoot_big = false
	$BigBombCD.start()
	var bomb = load("res://players/shotgun_mage/big_bomb.tscn").instantiate()
	bomb.set_velocity((get_global_mouse_position()-global_position).normalized()*BOMB_VELOCITY)
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
