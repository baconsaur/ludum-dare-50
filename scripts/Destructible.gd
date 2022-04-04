extends Node2D

var is_destroyed = false
var grid_pos = Vector2()

onready var sprite = $Sprite
onready var fix_sound = $Fix

func setup(pos):
	grid_pos = pos

func destroy():
	is_destroyed = true
	sprite.play("broken")

func fix():
	is_destroyed = false
	fix_sound.play()
	sprite.play("default")
