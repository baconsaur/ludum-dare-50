extends State

func _ready():
	VALID_INTERRUPTS = ["hunt"]

func enter():
	owner.sprite.play("default")
	owner.reset_energy()
	owner.request_path()
