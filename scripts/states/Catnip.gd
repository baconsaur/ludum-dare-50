extends State

var interact_timeout_seconds = 4
var cooldown = 0

func enter():
	owner.play_animation("catnip")
	owner.catnip_sound.play()
	cooldown = interact_timeout_seconds

func update(delta):
	if cooldown > 0:
		cooldown -= delta
		return

	_hunt_or_sleep()
