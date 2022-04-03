extends State

var sleep_timeout_seconds = 0.5
var cooldown = 0

func _ready():
	VALID_INTERRUPTS = ["wake"]

func enter():
	owner.sprite.play("sleep")
	cooldown = sleep_timeout_seconds

func update(delta):
	if cooldown > 0:
		cooldown -= delta
		return
	owner.increase_energy(1)
	
	cooldown = sleep_timeout_seconds
