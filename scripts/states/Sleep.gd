extends State

var sleep_timeout_seconds = 0.4
var cooldown = 0
var started = false

func _ready():
	VALID_INTERRUPTS = ["wake"]

func enter():
	started = false
	if owner.tween.is_active():
		yield(owner.tween, "tween_all_completed")
	started = true
	
	owner.play_animation("sleep")
	cooldown = sleep_timeout_seconds

func update(delta):
	if not started:
		return

	if cooldown > 0:
		cooldown -= delta
		return
	owner.increase_energy(1)
	
	cooldown = sleep_timeout_seconds

