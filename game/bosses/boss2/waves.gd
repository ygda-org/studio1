extends BaseState

var waves = []

const WAVE_SPEED = 100
const WAVE = preload("uid://cc1jd47ign5tn")
var dir = 0
var alternation = 1

func activate():
	super()
	alternation = 1
	if NetworkState.is_server():
		dir = -1#randi_range(0,1)*2-1
		if dir == -1:
			$AnimationPlayer.play("StartRight")
		else:
			$AnimationPlayer.play("StartLeft")
		set_dir.rpc(dir)
	$CD.start()

@rpc ("call_remote", "authority")
func set_dir(d):
	dir = d
	if dir == -1:
		$AnimationPlayer.play("StartRight")
	else:
		$AnimationPlayer.play("StartLeft")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for wave in waves:
		wave.position.x += WAVE_SPEED * dir * delta


func _on_cd_timeout():
	if alternation == 1:
		$AnimationPlayer.play("Up")
	elif alternation == -1:
		$AnimationPlayer.play("Down")
	var wav = WAVE.instantiate()
	waves.append(wav)
	boss.get_parent().add_child(wav)
	wav.position = boss.position
	wav.position.y -= 5 * alternation
	alternation = 1 if alternation == -1 else -1
	if active:
		$CD.start()
