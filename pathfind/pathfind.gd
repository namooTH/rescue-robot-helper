extends Node
@export var tile_container: TileContainer

enum IsMovable {
	No = 0,
	Yes = 1,
	Maybe = 2
}

func check_height_move(A, B, direction: Height.Direction, direction_op: Height.Direction):
	if A.height.surface == Height.Surface.above and B.height.surface == Height.Surface.ground:
		if A.height.direction == direction_op:
			return IsMovable.Yes
		return IsMovable.No
	elif A.height.surface == Height.Surface.ground and B.height.surface == Height.Surface.above:
		if B.height.direction == direction:
			return IsMovable.Yes
		return IsMovable.No
	elif A.height.surface == Height.Surface.ground and B.height.surface == Height.Surface.ground:
		return null
	else:
		if B.height.direction in [Height.Direction.none, direction_op]:
			return IsMovable.Yes
		if A.height.direction == direction_op:
			return IsMovable.Yes
		return IsMovable.No

func can_move(x: int, y: int, nx: int, ny: int) -> IsMovable:
	var A = tile_container.get_tile(x, y)
	var B = tile_container.get_tile(nx, ny)

	if A == null or B == null:
		return IsMovable.No

	# right (x + 1, y)
	if nx == x + 1 and ny == y:
		if A.wall.right:
			return IsMovable.No
		if B.wall.left:
			return IsMovable.No
		
		var can_height_move = check_height_move(A, B, Height.Direction.right, Height.Direction.left)
		if can_height_move != null:
			return can_height_move
		
		return IsMovable.Yes

	# left (x - 1, y)
	if nx == x - 1 and ny == y:
		if A.wall.left:
			return IsMovable.No
		if B.wall.right:
			return IsMovable.No
			
		var can_height_move = check_height_move(A, B, Height.Direction.left, Height.Direction.right)
		if can_height_move != null:
			return can_height_move
		
		return IsMovable.Yes

	# down (x, y + 1)
	if nx == x and ny == y + 1:
		if A.wall.down:
			return IsMovable.No
		if B.wall.up:
			return IsMovable.No

		var can_height_move = check_height_move(A, B, Height.Direction.down, Height.Direction.up)
		if can_height_move != null:
			return can_height_move

		return IsMovable.Yes

	# up (x, y - 1)
	if nx == x and ny == y - 1:
		if A.wall.up:
			return IsMovable.No
		if B.wall.down:
			return IsMovable.No

		var can_height_move = check_height_move(A, B, Height.Direction.up, Height.Direction.down)
		if can_height_move != null:
			return can_height_move

		return IsMovable.Yes

	if B.obstacle.type == Obstacle.Type.bar:
		return IsMovable.Maybe


	return IsMovable.No

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
		var movables: Array[IsMovable] = []
		
		for n in neighbors:
			movables.append(can_move(x, y, n.x, n.y))
		
		# this will check if there are less than 2 possible
		# normal moves.
		# if there are, it will try to move to the
		# most unlikely path which are flagged with IsMovable.Maybe
		#
		# this is used when theres no where to go in the path.
		
		var only_way_to_move: bool = (IsMovable.Maybe in movables and len(movables.filter(func(n): return n == IsMovable.Yes)) <= 1)
			
		for ninx in range(len(neighbors)):
			var n: Vector2i = neighbors[ninx]
			var m: IsMovable = movables[ninx]
			
			if not only_way_to_move and m == IsMovable.Maybe:
				continue

			if movables[ninx] != IsMovable.No:
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
