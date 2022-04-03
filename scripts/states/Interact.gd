extends State

var interact_timeout_seconds = 1
var cooldown = 0

func enter():
	owner.sprite.play("play")
	cooldown = interact_timeout_seconds

func update(delta):
	if cooldown > 0:
		cooldown -= delta
		return

	emit_signal("finished", "hunt")
