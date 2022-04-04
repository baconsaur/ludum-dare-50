extends State

var move_timeout_seconds = 0.3
var cooldown = 0
var last_position = Vector2()
var meow_chance = 0.15

func _ready():
	randomize()
	VALID_INTERRUPTS = ["sleep", "pet", "treat", "catnip", "destroy"]

func enter():
	cooldown = 0
	last_position = owner.position

func update(delta):
	if owner.tween.is_active():
		return

	last_position = owner.position
	owner.path_step()
	
	owner.tween.interpolate_property(owner, "position", last_position, owner.target_position, move_timeout_seconds, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	owner.tween.start()
	
	if randf() <= meow_chance:
		owner.meow_sounds[randi() % len(owner.meow_sounds) -1].play()

	if owner.energy <= 0:
		emit_signal("finished", "sleep")
