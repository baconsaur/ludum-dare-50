extends Control

export var menu_scene = "res://scenes/Menu.tscn"
export var game_scene = "res://scenes/Game.tscn"

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene(menu_scene)
		
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene(game_scene)

func _on_RetryButton_pressed():
	get_tree().change_scene(game_scene)

func _on_MainMenuButton_pressed():
	get_tree().change_scene(menu_scene)

func _on_ExitButton_pressed():
	get_tree().quit()
