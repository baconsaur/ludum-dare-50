extends Node2D

export var max_energy = 10
export var start_state = "wake"

var energy = 0
var path = []

onready var sprite = $Sprite
onready var state_machine = $StateMachine

signal needs_path

func _ready():
	state_machine.initialize(start_state)

func reset_energy():
	energy = max_energy

func increase_energy(energy_gain):
	energy += energy_gain
	if energy >= max_energy:
		energy = max_energy
		state_machine.interrupt_state("wake")

func decrease_energy(energy_loss):
	energy -= energy_loss
	if energy <= 0:
		energy = 0
		state_machine.interrupt_state("sleep")

func request_path():
	emit_signal("needs_path", self)

func set_path(new_path):
	path = new_path
	state_machine.interrupt_state("hunt")
