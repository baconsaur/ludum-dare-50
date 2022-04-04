extends Area2D

export var max_energy = 12
export var start_state = "wake"
export var interact_cooldown_seconds = 1.2

var energy = 0
var path = []
var grid_pos = Vector2()
var current_direction = Vector2(-1, 1)
var target_position = Vector2()
var interact_cooldown = 0
var meow_sounds = []

onready var sprite = $Sprite
onready var collider = $CollisionShape2D
onready var state_machine = $StateMachine
onready var tween = $Tween
onready var room_controller = get_node("/root/Game/Room")
onready var purr_sound = $Purr
onready var eat_sound = $Eat
onready var catnip_sound = $Nip
onready var leaf_particles = $LeafParticles
onready var hearticles = $Hearticles

signal needs_path
signal change_position
signal interaction_received

func _ready():
	meow_sounds = $Meows.get_children()
	state_machine.initialize(start_state)

func _process(delta):
	if interact_cooldown > 0:
		interact_cooldown -= delta

func reset_energy():
	energy = max_energy

func increase_energy(energy_gain):
	energy += energy_gain
	if energy >= max_energy:
		energy = max_energy
		state_machine.interrupt_state("wake")

func decrease_energy(energy_loss):
	energy -= energy_loss

func request_path():
	emit_signal("needs_path", self)

func set_path(new_path):
	path = new_path
	state_machine.interrupt_state("hunt")

func path_step():
	if not path:
		request_path()
		return

	var old_grid_pos = grid_pos
	grid_pos = path.pop_front()
	current_direction = grid_pos - old_grid_pos
	
	if current_direction.x <= 0 and current_direction.y > 0:
		play_animation("run_se")
	elif current_direction.x < 0 and current_direction.y <= 0:
		play_animation("run_sw")
	elif current_direction.x > 0 and current_direction.y <= 0:
		play_animation("run_ne")
	elif current_direction.x <= 0 and current_direction.y < 0:
		play_animation("run_nw")
	
	target_position = room_controller.to_isometric(grid_pos.x, grid_pos.y)  # Ew
	decrease_energy(1)
	
	emit_signal("change_position", self)

func destroy_object():
	state_machine.interrupt_state("destroy")

func is_interactable():
	if interact_cooldown > 0:
		return false

	for state in state_machine.INTERACTION_STATES:
		if state in state_machine.current_state.VALID_INTERRUPTS:
			return true
	return false

func begin_interaction(interaction_name, interaction_data):
	interact_cooldown = interact_cooldown_seconds
	state_machine.interrupt_state(interaction_name)
	decrease_energy(interaction_data["energy_cost"])

func _on_Cat_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		emit_signal("interaction_received", self)

func play_animation(anim_name):
	if sprite.animation != anim_name:
		sprite.play(anim_name)
