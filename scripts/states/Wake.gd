extends State

func _ready():
	VALID_INTERRUPTS = ["hunt"]

func enter():
	owner.play_animation("default")
	owner.reset_energy()
	owner.request_path()
