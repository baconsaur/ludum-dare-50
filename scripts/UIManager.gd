extends Control

var pause_menu = preload("res://scenes/PauseMenu.tscn")


func _process(delta):
	if not get_tree().paused and Input.is_action_just_pressed("ui_cancel"):
		var pause_menu_instance = pause_menu.instance()
		add_child(pause_menu_instance)
