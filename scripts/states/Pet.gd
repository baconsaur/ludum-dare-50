extends State

var interact_timeout_seconds = 1
var cooldown = 0
var started = false

func enter():
	started = false
	if owner.tween.is_active():
		yield(owner.tween, "tween_all_completed")
	started = true
	
	owner.play_animation("pet")
	owner.purr_sound.play()
	owner.hearticles.set_emitting(true)
	cooldown = interact_timeout_seconds

func update(delta):
	if not started:
		return

	if cooldown > 0:
		cooldown -= delta
		return

	_hunt_or_sleep()
