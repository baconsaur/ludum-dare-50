extends Node2D

var is_destroyed = false
var grid_pos = Vector2()

onready var sprite = $Sprite

func setup(pos):
	grid_pos = pos

func destroy():
	is_destroyed = true
	sprite.play("broken")

func fix():
	is_destroyed = false
	sprite.play("default")
