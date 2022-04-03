extends State

var move_timeout_seconds = 0.25
var cooldown = 0

func _ready():
	VALID_INTERRUPTS = ["sleep", "interact"]

func enter():
	cooldown = 0

func update(delta):
	if cooldown > 0:
		cooldown -= delta
		return

	owner.path_step()
	
	cooldown = move_timeout_seconds
