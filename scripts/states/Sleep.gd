extends State

func _ready():
	VALID_INTERRUPTS = ["wake"]

func enter():
	# Display sleep behavior
	return

func update(_delta):
	print("sleeping")
	owner.increase_energy(1)
