extends State

var destroy_timeout_seconds = 0.6
var cooldown = 0
var started = false

func enter():
	started = false
	if owner.tween.is_active():
		yield(owner.tween, "tween_all_completed")
	started = true

	if owner.current_direction.x <= 0 and owner.current_direction.y > 0:
		owner.play_animation("destroy_se")
	elif owner.current_direction.x < 0 and owner.current_direction.y <= 0:
		owner.play_animation("destroy_sw")
	elif owner.current_direction.x > 0 and owner.current_direction.y <= 0:
		owner.play_animation("destroy_ne")
	elif owner.current_direction.x <= 0 and owner.current_direction.y < 0:
		owner.play_animation("destroy_nw")

	cooldown = destroy_timeout_seconds

func update(delta):
	if not started:
		return

	if cooldown > 0:
		cooldown -= delta
		return

	_hunt_or_sleep()
