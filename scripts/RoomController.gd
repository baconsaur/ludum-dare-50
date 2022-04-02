extends Node2D

export var room_scale_x = 8
export var room_scale_y = 6
export var start_grid_position = Vector2(0, 32)
export var tile_dimensions = Vector2(16, 8)

var grid = []
var cats = []

var grid_space_obj = preload("res://scenes/GridSpace.tscn")
var cat_obj = preload("res://scenes/Cat.tscn")

func _ready():
	randomize()
	start_grid_position.x = -room_scale_x * (tile_dimensions.x + tile_dimensions.y) / 2
	
	for x in range(room_scale_x):
		grid.append([])
		for y in range(room_scale_y):
			var grid_space = grid_space_obj.instance()
			add_child(grid_space)
			grid_space.position = to_isometric(x, y)
			grid[x].append(grid_space)
	
	spawn_cat()

func spawn_cat():
	var grid_x = randi() % len(grid)
	var grid_y = randi() % len(grid[0])
	
	var cat = cat_obj.instance()
	cat.connect("needs_path", self, "generate_path", [], CONNECT_DEFERRED)
	add_child(cat)
	cat.position = to_isometric(grid_x, grid_y)
	cats.append(cat)

func to_isometric(x, y):
	var iso_x = x + y
	var iso_y = y - x
	
	return start_grid_position + Vector2(iso_x, iso_y) * tile_dimensions

func generate_path(cat):
	print("path request received")
	var path = []
	cat.set_path(path)
