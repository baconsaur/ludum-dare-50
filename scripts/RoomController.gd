extends Node2D

export var room_scale_x = 8
export var room_scale_y = 6
export var start_grid_position = Vector2(0, 32)
export var tile_dimensions = Vector2(16, 8)
export var num_desctructibles = 3
export var destructibles_per_hunt = 2

var grid = []
var cats = []
var destructibles = []
var destroyed_destructibles = []
var a_star = null

var grid_space_obj = preload("res://scenes/GridSpace.tscn")
var cat_obj = preload("res://scenes/Cat.tscn")
var destructible_objs = [preload("res://scenes/Destructible.tscn")]
var game_over_scene = "res://scenes/GameOver.tscn"

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
	
	a_star = create_a_star_grid()
	
	for i in range(num_desctructibles):
		spawn_destructible()
	spawn_cat()

func spawn_destructible():
	var destructible_obj = destructible_objs[randi() % len(destructible_objs)]
	
	var grid_x = randi() % len(grid)
	var grid_y = randi() % len(grid[0])
	var grid_space = grid[grid_x][grid_y]
	
	if grid_space.occupying_destructible:
		spawn_destructible()
		return
	
	var destructible = destructible_obj.instance()
	destructible.setup(Vector2(grid_x, grid_y))
	grid_space.add_destructible(destructible, to_isometric(grid_x, grid_y))
	destructibles.append(destructible)

func spawn_cat():
	var grid_x = randi() % len(grid)
	var grid_y = randi() % len(grid[0])
	
	# TODO prevent overlapping cats too
	if grid[grid_x][grid_y].occupying_destructible:
		spawn_cat()
		return
	
	var cat = cat_obj.instance()
	cat.connect("needs_path", self, "generate_path", [], CONNECT_DEFERRED)
	cat.connect("change_position", self, "check_cat")
	add_child(cat)
	cat.position = to_isometric(grid_x, grid_y)
	cat.grid_pos = Vector2(grid_x, grid_y)
	cats.append(cat)

# TODO pull this out into shared util?
func to_isometric(x, y):
	var iso_x = x + y
	var iso_y = y - x
	
	return start_grid_position + Vector2(iso_x, iso_y) * tile_dimensions

func create_a_star_grid():
	var new_a_star = AStar2D.new()
	
	for x in room_scale_x:
		for y in room_scale_y:
			var cell_id = get_a_star_cell_id(Vector2(x, y))
			new_a_star.add_point(cell_id, Vector2(x, y))
	
	for x in room_scale_x:
		for y in room_scale_y:
			var cell_id = get_a_star_cell_id(Vector2(x, y))
			for neighbor in get_cell_neighbors(x, y):
				var neighbor_id = get_a_star_cell_id(neighbor)
				if new_a_star.has_point(neighbor_id):
					new_a_star.connect_points(cell_id, neighbor_id, true)
	
	return new_a_star

func get_a_star_cell_id(cell):
	return int(cell.y + cell.x * room_scale_y)

func generate_path(cat):
	var possible_destructibles = []
	for instance in destructibles:
		if not instance in destroyed_destructibles:
			possible_destructibles.append(instance)
	
	if not possible_destructibles:
		print("The game is supposed to be over now oops")
		return

	possible_destructibles.shuffle()

	var path = []
	var last_pos = cat.grid_pos
	for i in range(min(destructibles_per_hunt, len(possible_destructibles))):
		var target_pos = possible_destructibles[i].grid_pos
		var point_path = a_star.get_point_path(get_a_star_cell_id(last_pos), get_a_star_cell_id(target_pos))
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
		Vector2(x-1,y-1),
		Vector2(x+1,y+1),
		Vector2(x-1,y+1),
		Vector2(x+1,y-1),
	]

func check_cat(cat):
	for destructible in destructibles:
		if not destructible in destroyed_destructibles and destructible.grid_pos == cat.grid_pos:
			destroyed_destructibles.append(destructible)
			destructible.destroy()
			cat.destroy_object()

			if len(destructibles) == len(destroyed_destructibles):
				get_tree().change_scene(game_over_scene)
