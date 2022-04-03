extends Area2D

export var max_energy = 10
export var start_state = "wake"

var energy = 0
var path = []
var grid_pos = Vector2()

onready var sprite = $Sprite
onready var collider = $CollisionShape2D
onready var state_machine = $StateMachine
onready var room_controller = get_node("/root/Game/Room")

signal needs_path
signal change_position

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

func path_step():
	if not path:
		state_machine.interrupt_state("sleep")
		return

	grid_pos = path.pop_front()
	position = room_controller.to_isometric(grid_pos.x, grid_pos.y)  # Ew
	decrease_energy(1)
	
	emit_signal("change_position", self)

func destroy_object():
	state_machine.interrupt_state("destroy")

func _input(event):
	# TODO interaction types/cooldown
	if event is InputEventMouseButton:
		decrease_energy(2)
		state_machine.interrupt_state("interact")
