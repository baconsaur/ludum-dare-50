extends State

func enter():
	yield(get_tree().create_timer(2.0), "timeout")
	emit_signal("finished", "hunt")
