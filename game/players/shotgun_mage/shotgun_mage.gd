extends Node2D

const DAMAGE = 10 # no idea what numbers will be good

const NORMAL_RECOIL = 250
const BIG_RECOIL = 400
const BOMB_VELOCITY = 400

var can_shoot = true
var can_shoot_big = true

var last_mouse_pos = Vector2()

func _ready():
	GameState.shotgun_mage = self

func _process(_delta): # purely visual stuff
	$Anim.position = Vector2(5, 0)
	if get_parent().is_on_floor():
		if int(get_parent().velocity.x) > 0:
			$ShotgunHelper/Arm.flip_v = false
			$ShotgunHelper/Shotgun.flip_v = false
			scale.x = 1
			$Anim.position = Vector2(4, -1)
			$Anim.play("run")
		elif int(get_parent().velocity.x) < 0:
			$ShotgunHelper/Arm.flip_v = true
			$ShotgunHelper/Shotgun.flip_v = true
			scale.x = -1
			$Anim.position = Vector2(4, -1)
			$Anim.play("run")
		else:
			$Anim.play("idle")
	else:
		$Anim.play("idle") # later, jump
	if last_mouse_pos.x > global_position.x:
		$ShotgunHelper.scale.x = 1
		$ShotgunHelper.look_at(last_mouse_pos)
	else:
		$ShotgunHelper.scale.x = -1
		$ShotgunHelper.look_at(last_mouse_pos) 
		$ShotgunHelper.rotation += PI

func process_input(input):
	last_mouse_pos = input.mouse_pos
	if get_parent().intro_lock:
		return
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
