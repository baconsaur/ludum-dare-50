extends Area2D

export var max_energy = 10
export var start_state = "wake"

var energy = 0
var path = []
var grid_pos = Vector2()
var current_direction = Vector2(-1, 1)
var target_position = Vector2()

onready var sprite = $Sprite
onready var collider = $CollisionShape2D
onready var state_machine = $StateMachine
onready var tween = $Tween
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

	var old_grid_pos = grid_pos
	grid_pos = path.pop_front()
	current_direction = grid_pos - old_grid_pos
	
	if current_direction.x == 0 and current_direction.y > 0:
		play_animation("run_se")
	elif current_direction.x < 0 and current_direction.y == 0:
		play_animation("run_sw")
	elif current_direction.x > 0 and current_direction.y == 0:
		play_animation("run_ne")
	elif current_direction.x == 0 and current_direction.y < 0:
		play_animation("run_nw")
	
	target_position = room_controller.to_isometric(grid_pos.x, grid_pos.y)  # Ew
	decrease_energy(1)
	
	emit_signal("change_position", self)

func destroy_object():
	state_machine.interrupt_state("destroy")
	
	if current_direction.x == 0 and current_direction.y > 0:
		play_animation("destroy_se")
	elif current_direction.x < 0 and current_direction.y == 0:
		play_animation("destroy_sw")
	elif current_direction.x > 0 and current_direction.y == 0:
		play_animation("destroy_ne")
	elif current_direction.x == 0 and current_direction.y < 0:
		play_animation("destroy_nw")

func _on_Cat_input_event(viewport, event, shape_idx):
	# TODO interaction types/cooldown
	if event is InputEventMouseButton:
		decrease_energy(2)
		state_machine.interrupt_state("interact")

func play_animation(anim_name):
	if sprite.animation != anim_name:
		sprite.play(anim_name)
