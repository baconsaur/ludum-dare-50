extends Control

export var menu_scene = "res://scenes/Menu.tscn"


func _ready():
	get_tree().paused = true

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		unpause()

func _on_ResumeButton_pressed():
	unpause()

func _on_MainMenuButton_pressed():
	unpause()
	get_tree().change_scene(menu_scene)

func _on_ExitButton_pressed():
	get_tree().quit()

func unpause():
	get_tree().paused = false
	queue_free()
