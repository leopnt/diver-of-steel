#tool
extends TileMap

export(int)   var map_w         = 80
export(int)   var map_h         = 50
export(int)   var iterations    = 20000
export(int)   var neighbors     = 4
export(int)   var ground_chance = 48
export(int)   var min_cave_size = 80

enum Tiles { GROUND, ROOF }
var caves = []


#export(bool)  var redraw  setget redraw
#
#func redraw(value = null):
#
#	# only do this if we are working in the editor
#	if !Engine.is_editor_hint():
#		return
#
#	generate()


func _ready():
	generate()


func generate():
	clear()
	fill_roof()
	random_ground()
	dig_caves()
	get_caves()
	#connect_caves()


func fill_roof():
	for x in range(0, map_w):
		for y in range(0, map_h):
			set_cell(x, y, Tiles.ROOF)


func random_ground():
	for x in range(1, map_w-1):
		for y in range(1, map_h-1):
			if chance(ground_chance):
				set_cell(x, y, Tiles.GROUND)


func dig_caves():
	randomize()
	for _i in range(iterations):
		# Pick a random point with a 1-tile buffer within the map
		var x = floor(rand_range(1, map_w-1))
		var y = floor(rand_range(1, map_h-1))

		# if nearby cells > neighbors, make it a roof tile
		if check_nearby(x,y) > neighbors:
			set_cell(x, y, Tiles.ROOF)

		# or make it the ground tile
		elif check_nearby(x,y) < neighbors:
			set_cell(x, y, Tiles.GROUND)


func check_nearby(x, y):
	var count = 0
	if get_cell(x, y-1)   == Tiles.ROOF:  count += 1
	if get_cell(x, y+1)   == Tiles.ROOF:  count += 1
	if get_cell(x-1, y)   == Tiles.ROOF:  count += 1
	if get_cell(x+1, y)   == Tiles.ROOF:  count += 1
	if get_cell(x+1, y+1) == Tiles.ROOF:  count += 1
	if get_cell(x+1, y-1) == Tiles.ROOF:  count += 1
	if get_cell(x-1, y+1) == Tiles.ROOF:  count += 1
	if get_cell(x-1, y-1) == Tiles.ROOF:  count += 1
	return count


# the percent chance something happens
func chance(num)->bool:
	randomize()
	
	if randi() % 100 <= num:
		return true
	else:
		return false

# Util.choose(["one", "two"])   returns one or two
func choose(choices):
	randomize()

	var rand_index = randi() % choices.size()
	return choices[rand_index]


func get_caves():
	caves = []

	for x in range (0, map_w):
		for y in range (0, map_h):
			if get_cell(x, y) == Tiles.GROUND:
				flood_fill(x,y)

	for cave in caves:
		for tile in cave:
			set_cellv(tile, Tiles.GROUND)


func flood_fill(tilex, tiley):
	var cave = []
	var to_fill = [Vector2(tilex, tiley)]
	while to_fill:
		var tile = to_fill.pop_back()

		if !cave.has(tile):
			cave.append(tile)
			set_cellv(tile, Tiles.ROOF)

			#check adjacent cells
			var north = Vector2(tile.x, tile.y-1)
			var south = Vector2(tile.x, tile.y+1)
			var east  = Vector2(tile.x+1, tile.y)
			var west  = Vector2(tile.x-1, tile.y)

			for dir in [north,south,east,west]:
				if get_cellv(dir) == Tiles.GROUND:
					if !to_fill.has(dir) and !cave.has(dir):
						to_fill.append(dir)

	if cave.size() >= min_cave_size:
		caves.append(cave)
