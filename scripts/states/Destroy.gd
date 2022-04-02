extends State

func enter():
	print("destroying")
	yield(get_tree().create_timer(2.0), "timeout")
	emit_signal("finished", "hunt")
