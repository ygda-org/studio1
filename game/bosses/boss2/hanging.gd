extends BaseState

var boss_glow
@export var glow_gradient: GradientTexture2D
@export var glow_color: Color

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("activating", activation)

func activation():
	boss_glow = PointLight2D.new()
	boss_glow.color = glow_color
	boss_glow.position.y -= 60
	boss_glow.texture = glow_gradient
	boss.velocity = Vector2.ZERO
	boss.position = Vector2(-10, -300)
	$AnimationPlayer.play("Darken")
	boss.segments[0].rotation = PI
	add_child(boss_glow)

func deactivate():
	if active:
		if boss_glow:
			boss_glow.queue_free()
			boss_glow = null
		$AnimationPlayer.play_backwards("Darken")
	super()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not active:
		return
	boss.segments[0].rotation = PI


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Darken":
		$AnimationPlayer.play("Start")
