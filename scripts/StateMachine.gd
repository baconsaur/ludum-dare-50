extends Node

signal state_changed(current_state)

var states_map = {}
var current_state = null


func _ready():
	states_map = {
		"sleep": $Sleep,
		"wake": $Wake,
		"hunt": $Hunt,
		"interact": $Interact,
		"destroy": $Destroy,
	}
	for child in get_children():
		child.connect("finished", self, "_change_state")

func initialize(start_state):
	current_state = states_map[start_state]
	current_state.enter()

func interrupt_state(new_state):
	if new_state in current_state.VALID_INTERRUPTS:
		_change_state(new_state)

func _process(delta):
	current_state.update(delta)

func _change_state(new_state):
	current_state.exit()
	
	current_state = states_map[new_state]
	current_state.enter()
	
	emit_signal("state_changed", current_state)

func _on_animation_finished():
	current_state._on_animation_finished(owner.sprite.animation)
