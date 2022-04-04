extends Node
class_name State

var VALID_INTERRUPTS = []

signal finished(next_state_name)

func enter():
	return

func exit():
	return

func update(_delta):
	return

func _on_animation_finished(_anim_name):
	return

func _hunt_or_sleep():
	if owner.energy <= 0:
		emit_signal("finished", "sleep")
		owner.play_animation("sleep") # Quick hack to fix the long interaction bug, fix properly later
	else:
		emit_signal("finished", "hunt")
