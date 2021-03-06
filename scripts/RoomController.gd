extends Node2D

export var start_grid_position = Vector2(0, 32)
export var tile_dimensions = Vector2(16, 8)
export var num_desctructibles = 8
export var destructibles_per_hunt = 1

var floor_tiles = ["wood", "carpet"]
var wall_tiles = ["wall_xn", "wall_x", "wall_xs", "wall_yn", "wall_y", "wall_ys", "pillar", "wall_br", "wall_bl", "wall_blx", "wall_bry", "blank", "couch_l", "couch_r"]
var grid_map = [
	["wall_bl", "wood", "wood", "wood", "wall_yn", "wood", "wood", "wood", "wood", "wood", "wood"],
	["wall_bl", "wood", "wood", "wood", "wall_y", "wood", "wood", "wood", "wood", "wood", "wood"],
	["wall_bl", "wood", "wood", "wood", "wall_y", "wood", "wood", "wood", "wood", "wood", "wood"],
	["wall_blx", "wall_x", "wall_xs", "wood", "wall_ys", "wood", "wood", "wood", "wood", "wood", "wood"],
	["wall_bl", "wood", "wood", "wood", "wood", "wood", "wood", "wood", "wood", "wood", "wood"],
	["wall_bl", "wood", "carpet", "carpet", "carpet", "carpet", "wood", "wall_yn", "wood", "wood", "wood"],
	["wall_bl", "wood", "carpet", "carpet", "carpet", "carpet", "wood", "wall_y", "wood", "wood", "wood"],
	["wall_bl", "wood", "carpet", "carpet", "carpet", "carpet", "wood", "wall_y", "wood", "wood", "wood"],
	["wall_bl", "wood", "carpet", "carpet", "carpet", "carpet", "wood", "wall_y", "wood", "wood", "wood"],
	["wall_bl", "wood", "wood", "couch_l", "couch_r", "wood", "wood", "wall_y", "wood", "wood", "wood"],
	["blank", "wall_br", "wall_br", "wall_br", "wall_br", "wall_br", "wall_br", "wall_bry", "wall_br", "wall_br", "wall_br"],
]
var grid = []
var cats = []
var destructibles = []
var destroyed_destructibles = []
var a_star = null

var grid_space_obj = preload("res://scenes/GridSpace.tscn")
var grid_wall_obj = preload("res://scenes/GridWall.tscn")
var cat_obj = preload("res://scenes/Cat.tscn")
var destructible_objs = [preload("res://scenes/Destructible.tscn")]
var game_over_scene = "res://scenes/GameOver.tscn"
var cat_skins = [
	preload("res://sprites/cat1_frames.tres"),
	preload("res://sprites/cat2_frames.tres"),
	preload("res://sprites/cat3_frames.tres"),
	preload("res://sprites/cat4_frames.tres"),
]
var destructible_skins = [preload("res://sprites/destructible1_frames.tres"), preload("res://sprites/destructible2_frames.tres"), preload("res://sprites/destructible3_frames.tres")]

signal cat_interaction

func _ready():
	randomize()
	start_grid_position.x = -len(grid_map[0]) * (tile_dimensions.x + tile_dimensions.y) / 2

	# Make the grid
	for x in range(len(grid_map)):
		grid.append([])
		for y in range(len(grid_map[x])):
			var grid_space
			if grid_map[x][y] in wall_tiles:
				grid_space = grid_wall_obj.instance()
			else:
				grid_space = grid_space_obj.instance()
			grid[x].append(grid_space)
	
	# Draw the grid in correct render order
	for y in range(len(grid_map[0])):
		for x in range(len(grid_map) - 1, -1, -1):
			var grid_space = grid[x][y]
			add_child(grid_space)
			grid_space.position = to_isometric(x, y)
			grid_space.sprite.play(grid_map[x][y])
	
	a_star = create_a_star_grid()

	for i in range(num_desctructibles):
		spawn_destructible()
	spawn_cat()


func create_a_star_grid():
	var new_a_star = AStar2D.new()
	
	for x in len(grid):
		for y in len(grid[0]):
			if grid_map[x][y] in wall_tiles:
				continue
			var cell_id = grid_indices_to_cell_id(x, y)
			new_a_star.add_point(cell_id, Vector2(x, y))
	
	for x in len(grid):
		for y in len(grid[0]):
			if grid_map[x][y] in wall_tiles:
				continue
			var cell_id = grid_indices_to_cell_id(x, y)
			for neighbor in get_cell_neighbors(x, y):
				var neighbor_id = grid_indices_to_cell_id(neighbor.x, neighbor.y)
				if new_a_star.has_point(neighbor_id):
					new_a_star.connect_points(cell_id, neighbor_id, true)
	
	return new_a_star


func to_isometric(x, y):
	var iso_x = x + y
	var iso_y = y - x

	return start_grid_position + Vector2(iso_x, iso_y) * tile_dimensions

func spawn_destructible():
	var destructible_obj = destructible_objs[randi() % len(destructible_objs)]

	var grid_x = randi() % len(grid)
	var grid_y = randi() % len(grid[0])
	var grid_space = grid[grid_x][grid_y]

	if grid_map[grid_x][grid_y] in wall_tiles or grid_space.occupying_destructible:
		spawn_destructible()
		return

	var destructible = destructible_obj.instance()
	destructible.setup(Vector2(grid_x, grid_y))
	grid_space.add_destructible(destructible, grid_space.position)
	
	var destructible_skin = destructible_skins[randi() % len(destructible_skins)]
	destructible.sprite.set_sprite_frames(destructible_skin)

	destructibles.append(destructible)

func spawn_cat():
	var grid_x = randi() % len(grid)
	var grid_y = randi() % len(grid[0])

	# TODO prevent overlapping cats too
	var current_grid_space = grid[grid_x][grid_y]
	if grid_map[grid_x][grid_y] in wall_tiles or current_grid_space.occupying_destructible:
		spawn_cat()
		return

	var cat = cat_obj.instance()
	cat.connect("needs_path", self, "generate_path", [], CONNECT_DEFERRED)
	cat.connect("change_position", self, "check_cat")
	cat.connect("interaction_received", self, "handle_cat_interaction")
	add_child(cat)
	
	randomize()
	var cat_skin = cat_skins[randi() % len(cat_skins)]
	cat.sprite.set_sprite_frames(cat_skin)
	
	cat.position = to_isometric(grid_x, grid_y)
	cat.grid_pos = Vector2(grid_x, grid_y)
	
	var pos_in_parent = current_grid_space.get_position_in_parent()
	move_child(cat, pos_in_parent + 1)
	
	cats.append(cat)

func grid_indices_to_cell_id(x, y):
	return x * len(grid) + y

func generate_path(cat):
	var possible_destructibles = []
	for instance in destructibles:
		if not instance.is_destroyed:
			possible_destructibles.append(instance)

	possible_destructibles.shuffle()

	var path = []
	var last_pos = cat.grid_pos
	for i in range(min(destructibles_per_hunt, len(possible_destructibles))):
		var target_pos = possible_destructibles[i].grid_pos
		var point_path = a_star.get_point_path(
			grid_indices_to_cell_id(last_pos.x, last_pos.y),
			grid_indices_to_cell_id(target_pos.x, target_pos.y)
		)
		last_pos = target_pos

		for point in point_path:
			path.append(Vector2(point.x, point.y))

	cat.set_path(path)

func get_cell_neighbors(x, y):
	return [
		Vector2(x,y-1),
		Vector2(x,y+1),
		Vector2(x-1,y),
		Vector2(x+1,y),
#		Vector2(x-1,y-1),  # Do I want to do a diagonal animation? NOT REALLY
#		Vector2(x+1,y+1),
#		Vector2(x-1,y+1),
#		Vector2(x+1,y-1),
	]

func check_cat(cat):
	var grid_space = grid[cat.grid_pos.x][cat.grid_pos.y]
	var pos_in_parent = grid_space.get_position_in_parent()
	move_child(cat, pos_in_parent + 1)
	
	var destructible = grid_space.occupying_destructible

	if not destructible or destructible.is_destroyed:
		return

	destructible.destroy()
	destroyed_destructibles.append(destructible)
	cat.destroy_object()
	
	var possible_destructibles = []
	for instance in destructibles:
		if not instance.is_destroyed:
			possible_destructibles.append(instance)
	
	if not possible_destructibles:
		get_tree().change_scene(game_over_scene)

func handle_cat_interaction(cat):
	emit_signal("cat_interaction", cat)

func fix_destructible():
	if destroyed_destructibles:
		var destructible = destroyed_destructibles.pop_front()
		destructible.get_parent().sparkle()
		destructible.fix()
	else:
		spawn_destructible()
