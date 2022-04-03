extends TextureButton


export var cost = 0

func _ready():
	var label = $Label
	if label:
		label.text = "$" + str(cost)
