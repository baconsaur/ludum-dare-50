extends State

func _ready():
	VALID_INTERRUPTS = ["hunt"]

func enter():
	print("start waking")
	owner.reset_energy()
	owner.request_path()
