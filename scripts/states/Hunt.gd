extends State


func _ready():
	VALID_INTERRUPTS = ["sleep", "interact"]

func enter():
	pass

func update(_delta):
	print("hunting")
	owner.decrease_energy(1)
	# TODO end early if we run out of path
