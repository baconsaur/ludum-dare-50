extends Node2D

export var max_energy = 10
var energy = 0

onready var sprite = $Sprite

func _ready():
	energy = max_energy
