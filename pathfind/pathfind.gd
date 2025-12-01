extends Node
@onready var tile_container = $"../MarginContainer/HFlowContainer/Editor/MarginContainer/HSplitContainer/AspectRatioContainer/TileContainer"

func check_height_move(A, B, direction: Height.Direction, direction_op: Height.Direction):
	if A.height.surface == Height.Surface.above and B.height.surface == Height.Surface.ground:
		if A.height.direction == direction_op:
			return true
		return false
	elif A.height.surface == Height.Surface.ground and B.height.surface == Height.Surface.above:
		if B.height.direction == direction:
			return true
		return false
	elif A.height.surface == Height.Surface.ground and B.height.surface == Height.Surface.ground:
		return null
	else:
		if B.height.direction in [Height.Direction.none, direction_op]:
			return true
		if A.height.direction == direction_op:
			return true
		return false
	
func can_move(x: int, y: int, nx: int, ny: int) -> bool:
	var A = tile_container.get_tile(x, y)
	var B = tile_container.get_tile(nx, ny)

	if A == null or B == null:
		return false
	
	if B.obstacle.type == Obstacle.Type.bar:
		return false

	# right (x + 1, y)
	if nx == x + 1 and ny == y:
		if A.wall.right:
			return false
		if B.wall.left:
			return false
		
		var can_height_move = check_height_move(A, B, Height.Direction.right, Height.Direction.left)
		if can_height_move != null:
			return can_height_move
		
		return true

	# left (x - 1, y)
	if nx == x - 1 and ny == y:
		if A.wall.left:
			return false
		if B.wall.right:
			return false
			
		var can_height_move = check_height_move(A, B, Height.Direction.left, Height.Direction.right)
		if can_height_move != null:
			return can_height_move
		
		return true

	# down (x, y + 1)
	if nx == x and ny == y + 1:
		if A.wall.down:
			return false
		if B.wall.up:
			return false

		var can_height_move = check_height_move(A, B, Height.Direction.down, Height.Direction.up)
		if can_height_move != null:
			return can_height_move

		return true

	# up (x, y - 1)
	if nx == x and ny == y - 1:
		if A.wall.up:
			return false
		if B.wall.down:
			return false

		var can_height_move = check_height_move(A, B, Height.Direction.up, Height.Direction.down)
		if can_height_move != null:
			return can_height_move

		return true

	return false

func heuristic(a: Vector2i, b: Vector2i) -> int:
	return abs(a.x - b.x) + abs(a.y - b.y)

func reconstruct_path(came_from, current):
	var path = [current]
	while came_from.has(current):
		current = came_from[current]
		path.append(current)
	path.reverse()
	return path

func astar(start: Vector2i, goal: Vector2i) -> Array:
	var pq = priority_queue.new(func(a, b): return a["f"] > b["f"])
	pq.push({"pos": start, "f": 0})

	var came_from = {}
	var g_score = {start: 0}

	while !pq.empty():
		var current = pq.top()["pos"]
		pq.pop();

		if current == goal:
			return reconstruct_path(came_from, current)

		var x = current.x
		var y = current.y

		var neighbors = [
			Vector2i(x + 1, y),
			Vector2i(x - 1, y),
			Vector2i(x, y + 1),
			Vector2i(x, y - 1)
		]

		for n in neighbors:
			if can_move(x, y, n.x, n.y):
				var tentative = g_score[current] + 1

				if not g_score.has(n) or tentative < g_score[n]:
					g_score[n] = tentative
					var f = tentative + heuristic(n, goal)
					pq.push({"pos": n, "f": f})
					came_from[n] = current

	return []

func astar_closest_tiles(start: Vector2i, tiles: Array):
	var closest_tile = []
	for tile in tiles:
		var tile_vec = tile.name.split("-")
		var path = astar(start, Vector2i(int(tile_vec[0]), int(tile_vec[1])))
		if closest_tile:
			if path and len(path) < len(closest_tile):
				closest_tile = path
		else:
			closest_tile = path
	
	return closest_tile
	
var dices = []
var points = []
var starting_pos = Vector2i(0,3)

func _on_button_2_pressed() -> void:
	dices.clear()
	points.clear()
	starting_pos = Vector2i(0,3)
	for tile in tile_container.get_children():
		if tile.dice.direction != Dice.Direction.none:
			dices.append(tile)
		if tile.extra.type == Extra.Type.point:
			points.append(tile)

func _on_button_pressed() -> void:
	var dice = astar_closest_tiles(starting_pos, dices)
	var point = astar_closest_tiles(starting_pos, points)
	var path
	if len(point) != 0 and len(point) < len(dice):
		path = point
		if path:
			points.erase(tile_container.get_tile(point[-1].x, point[-1].y))
	elif len(dice) != 0:
		path = dice
		if path:
			dices.erase(tile_container.get_tile(dice[-1].x, dice[-1].y))
	else:
		path = point
		if path:
			points.erase(tile_container.get_tile(point[-1].x, point[-1].y))
	
	if len(path) == 0:
		path = astar(starting_pos, Vector2i(0,3))
		
	var line := $"../Line2D"
	line.clear_points()

	for p in path:
		var tile = tile_container.get_tile(p.x, p.y)
		var pos = tile.global_position + (tile.size / 2)
		line.add_point(pos)
	
	starting_pos = path[-1]
