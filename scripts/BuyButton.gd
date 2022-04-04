extends TextureButton


export var cost = 0

func _ready():
	$Label.text = "$" + str(cost)
