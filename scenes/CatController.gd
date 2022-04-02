extends Node2D

export var max_energy = 10
var energy = 0

onready var sprite = $Sprite
onready var state_machine = $StateMachine

func _ready():
	energy = max_energy
	state_machine.initialize()
