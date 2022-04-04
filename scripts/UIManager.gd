extends Control

var pause_menu = preload("res://scenes/PauseMenu.tscn")
var buy_button = preload("res://scenes/buttons/BuyButton.tscn")
var use_button = preload("res://scenes/buttons/UseButton.tscn")
var buy_button_class = preload("res://scripts/BuyButton.gd")
var use_button_group = preload("res://scenes/buttons/UseButtonGroup.tres")
var sound_on_texture = preload("res://sprites/sound_controls3.png")
var sound_off_texture = preload("res://sprites/sound_controls4.png")

var sound_on = true
var default_button = null
var button_config = {
	"pet": {
		"icon": preload("res://sprites/heart_icon.png"),
		"cost": 0,
		"button": null,
	},
	"treat": {
		"icon": preload("res://sprites/treat_icon.png"),
		"cost": 3,
		"button": null,
	},
	"catnip": {
		"icon": preload("res://sprites/catnip_icon.png"),
		"cost": 7,
		"button": null,
	},
	"fix": {
		"icon": preload("res://sprites/fix_icon.png"),
		"cost": 15,
		"button": null,
	},
}

onready var dollar_label = $NinePatchRect/VBoxContainer/Dollars
onready var button_container = $NinePatchRect/VBoxContainer
onready var sound_control = $NinePatchRect/SoundControl
onready var music = get_node("/root/Music")
onready var sound_bus = AudioServer.get_bus_index("Master")

signal buy_item
signal set_active_tool

func _ready():
	var current_volume = db2linear(AudioServer.get_bus_volume_db(sound_bus))
	if current_volume == 0:
		sound_on = false
		toggle_sound_icon()
	
	for config in button_config:
		var button
		if config == "pet":
			button = create_use_button(config)
			button.set_pressed(true)
			default_button = button
		else:
			button = create_buy_button(config, button_config[config]["cost"])
		button_config[config]["button"] = button
		button_container.add_child(button)
		button.get_node("Icon").texture = button_config[config]["icon"]

func toggle_sound_icon():
	if sound_on:
		sound_control.set_normal_texture(sound_on_texture)
	else:
		sound_control.set_normal_texture(sound_off_texture)

func _process(delta):
	if not get_tree().paused and Input.is_action_just_pressed("ui_cancel"):
		var pause_menu_instance = pause_menu.instance()
		add_child(pause_menu_instance)

func set_dollars(amount):
	dollar_label.text = "$" + str(amount)
	for child in button_container.get_children():
		if child is buy_button_class:
			if amount < child.cost:
				child.disabled = true
			else:
				child.disabled = false

func toggle_default():
	default_button.set_pressed(true)

func replace_button(old, new, button_name):
	var pos_in_parent = old.get_position_in_parent()
	button_container.remove_child(old)
	button_container.add_child(new)
	
	new.get_node("Icon").texture = button_config[button_name]["icon"]
	
	button_container.move_child(new, pos_in_parent)
	old.queue_free()
	button_config[button_name]["button"] = new

func use_item(item_name):
	if item_name == "pet":
		return

	var button = button_config[item_name]["button"]
	var new_button = create_buy_button(item_name, button_config[item_name]["cost"])
	
	replace_button(button, new_button, item_name)
	toggle_default()
	
func make_item_useable(item_name):
	var button = button_config[item_name]["button"]
	var new_button = create_use_button(item_name)
	
	replace_button(button, new_button, item_name)
	
	button_config[item_name]["button"] = new_button
	new_button.set_pressed(true)

func create_use_button(name):
	var button = use_button.instance()
	button.set_button_group(use_button_group)
	button.connect("toggled", self, name + "_toggled")
	return button

func create_buy_button(name, cost):
	var button = buy_button.instance()
	button.cost = cost
	button.connect("pressed", self, name + "_pressed")
	return button

func pet_toggled(button_pressed):
	if not button_pressed:
		return
	emit_signal("set_active_tool", "pet")

func treat_toggled(button_pressed):
	if not button_pressed:
		return
	emit_signal("set_active_tool", "treat")

func catnip_toggled(button_pressed):
	if not button_pressed:
		return
	emit_signal("set_active_tool", "catnip")

func treat_pressed():
	emit_signal("buy_item", "treat", button_config["treat"].cost)

func catnip_pressed():
	emit_signal("buy_item", "catnip", button_config["catnip"].cost)

func fix_pressed():
	emit_signal("buy_item", "fix", button_config["fix"].cost)

func _on_SoundControl_pressed():
	if sound_on:
		AudioServer.set_bus_volume_db(sound_bus, linear2db(0))
		sound_on = false
	else:
		AudioServer.set_bus_volume_db(sound_bus, linear2db(1))
		sound_on = true
		
	toggle_sound_icon()
