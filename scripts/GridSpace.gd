extends Node2D

var occupying_destructible = null

onready var sprite = $Sprite
onready var particles = $Particles2D

func add_destructible(instance, pos):
	add_child(instance)
	instance.position = pos - position + Vector2(0, instance.position.y)
	occupying_destructible = instance

func sparkle():
	particles.set_emitting(true)
