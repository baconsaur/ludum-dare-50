extends Node2D

export var money_gain_seconds = 5
export var money_gain_rate = 5

var money = 0
var money_gain_cooldown = 0
var current_tool_name = "pet"

onready var ui = $CanvasLayer/UI

var interaction_map = {
	"pet": {
		"cursor_image": preload("res://sprites/pet_cursor.png"),
		"hotspot": Vector2(7, 6),
		"energy_cost": 2,
		"is_interaction": true,
	},
	"treat": {
		"cursor_image": preload("res://sprites/treat_cursor.png"),
		"hotspot": Vector2(7, 6),
		"energy_cost": 4,
		"is_interaction": true,
	},
	"catnip": {
		"cursor_image": preload("res://sprites/catnip_cursor.png"),
		"hotspot": Vector2(7, 6),
		"energy_cost": 5,
		"is_interaction": true,
	},
	"scratching_post": {
		"cursor_image": preload("res://sprites/scratching_post_cursor.png"),
		"hotspot": Vector2(7, 6),
		"energy_cost": 0,
		"is_interaction": false,
	},
}

func _ready():
	$Room.connect("cat_interaction", self, "handle_cat_interaction")
	Input.set_custom_mouse_cursor(interaction_map["pet"]["cursor_image"], 0, interaction_map["pet"]["hotspot"])
	ui.connect("set_active_tool", self, "set_active_tool")
	ui.connect("buy_item", self, "buy_item")

func _process(delta):
	if money_gain_cooldown > 0:
		money_gain_cooldown -= delta
		return
	
	money += money_gain_rate
	ui.set_dollars(money)
	money_gain_cooldown = money_gain_seconds

func set_active_tool(tool_name):
	current_tool_name = tool_name
	Input.set_custom_mouse_cursor(interaction_map[tool_name]["cursor_image"], 0, interaction_map[tool_name]["hotspot"])

func buy_item(item_name, cost):
	money -= cost
	ui.set_dollars(money)
	ui.make_item_useable(item_name)

func handle_cat_interaction(cat):
	var interaction = interaction_map[current_tool_name]
	if interaction["is_interaction"] and cat.is_interactable():
		cat.begin_interaction(interaction)
		ui.use_item(current_tool_name)
