extends Node2D

var occupying_destructible = null

func add_destructible(instance, pos):
	add_child(instance)
	instance.position = pos - position + Vector2(0, instance.position.y)
	occupying_destructible = instance
