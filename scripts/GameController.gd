extends Node2D

export var money_gain_seconds = 5
export var money_gain_rate = 5

var money = 0
var money_gain_cooldown = 0

onready var ui = $CanvasLayer/UI

func _process(delta):
	if money_gain_cooldown > 0:
		money_gain_cooldown -= delta
		return
	
	money += money_gain_rate
	ui.set_dollars(money)
	money_gain_cooldown = money_gain_seconds
