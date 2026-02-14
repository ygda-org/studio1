extends BaseState

var boss_glow
@export var glow_gradient: GradientTexture2D
@export var glow_color: Color


const PROJECTILE_SPEED = 300
const PROJECTILE = preload("uid://d05mwq2yktdsv")
const SHOT = preload("uid://defoqes0q5vgm")

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("activating", activation)

func activation():
	if NetworkState.is_server():
		$Duration.start()
	boss_glow = PointLight2D.new()
	boss_glow.color = glow_color
	boss_glow.position.y -= 60
	boss_glow.texture = glow_gradient
	boss.velocity = Vector2.ZERO
	boss.position = Vector2(-10, -300)
	$AnimationPlayer.play("Darken")
	boss.segments[0].rotation = PI
	add_child(boss_glow)
	for p in GameState.players:
		p.get_parent().get_node("AnimationPlayer").play("light_on")

func deactivate():
	if active:
		super()
		boss.velocity = Vector2(0, -90)
		if boss_glow:
			boss_glow.queue_free()
			boss_glow = null
		$AnimationPlayer.play_backwards("Darken")
		for p in GameState.players:
			p.get_parent().get_node("AnimationPlayer").play_backwards("light_on")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not active:
		return
	boss.segments[0].rotation = PI


func _on_animation_player_animation_finished(anim_name):
	if not active:
		return
	if anim_name == "Darken":
		$AnimationPlayer.play("Start")
	elif anim_name == "Start":
		$ShootCD.start()
	elif anim_name == "Bounce":
		shoot.rpc()

@rpc ("call_local")
func shoot_anims():
	$AnimationPlayer.play("RESET")
	#$AnimationPlayer.queue("Bounce")

func _on_shoot_cd_timeout():
	if NetworkState.is_server() and active:
		$ShootCD.start()
		shoot_anims.rpc()
		shoot()

func shoot():
	var shot = SHOT.instantiate()
	shot.name = "shot" + str(GameState.elapsed_time)
	GameState.set_shot_velocity.rpc(boss.segments[0].global_position.direction_to(GameState.players.pick_random().global_position) * PROJECTILE_SPEED)
	boss.get_parent().add_child(shot)


func _on_duration_timeout():
	boss.phase_change.rpc()
