extends Node
@export var tile_container: TileContainer
@export var path_container: PathContainer

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

func can_move(x: int, y: int, nx: int, ny: int, check_height: bool = true) -> IsMovable:
	var A = tile_container.get_tile(x, y)
	var B = tile_container.get_tile(nx, ny)

	if A == null or B == null:
		return IsMovable.No

	# right (x + 1, y)
	if nx == x + 1 and ny == y:
		var can_height_move = check_height_move(A, B, Height.Direction.right, Height.Direction.left)
		if can_height_move != null:
			if check_height:
				return can_height_move
		else:
			if A.wall.right:
				return IsMovable.No
			if B.wall.left:
				return IsMovable.No
			
		
		return IsMovable.Yes

	# left (x - 1, y)
	if nx == x - 1 and ny == y:
		var can_height_move = check_height_move(A, B, Height.Direction.left, Height.Direction.right)
		if can_height_move != null:
			if check_height:
				return can_height_move
		else:
			if A.wall.left:
				return IsMovable.No
			if B.wall.right:
				return IsMovable.No
		
		return IsMovable.Yes

	# down (x, y + 1)
	if nx == x and ny == y + 1:
		var can_height_move = check_height_move(A, B, Height.Direction.down, Height.Direction.up)
		if can_height_move != null:
			if check_height:
				return can_height_move
		else:
			if A.wall.down:
				return IsMovable.No
			if B.wall.up:
				return IsMovable.No

		return IsMovable.Yes

	# up (x, y - 1)
	if nx == x and ny == y - 1:
		var can_height_move = check_height_move(A, B, Height.Direction.up, Height.Direction.down)
		if can_height_move != null:
			if check_height:
				return can_height_move
		else:
			if A.wall.up:
				return IsMovable.No
			if B.wall.down:
				return IsMovable.No

		return IsMovable.Yes

	if B.obstacle.type == Obstacle.Type.bar:
		return IsMovable.Maybe

	return IsMovable.No

func heuristic(a: Vector2i, b: Vector2i) -> int:
	return abs(a.x - b.x) + abs(a.y - b.y)

func reconstruct_path(came_from, current) -> Array[Vector2i]:
	var path: Array[Vector2i] = [current]
	while came_from.has(current):
		current = came_from[current]
		path.append(current)
	path.reverse()
	return path

func astar(start: Vector2i, goal: Vector2i) -> Array[Vector2i]:
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

func generate_actions(starting_pos: Vector2i = Vector2i(0,3)) -> Array[Action]:
	var actions: Array[Action] = []
	var dices = []
	var points = []
	
	for tile in tile_container.get_children():
		if tile.dice.direction != Dice.Direction.none:
			dices.append(tile)
		if tile.extra.type == Extra.Type.point:
			points.append(tile)
	
	while true:
		var dice = astar_closest_tiles(starting_pos, dices)
		var point = astar_closest_tiles(starting_pos, points)
		var path
		var action: Action.RobotAction = Action.RobotAction.Walk
		
		if len(point) != 0 and len(point) < len(dice):
			path = point
			action = Action.RobotAction.Point
			if path:
				points.erase(tile_container.get_tile(point[-1].x, point[-1].y))
		elif len(dice) != 0:
			path = dice
			action = Action.RobotAction.Dice
			if path:
				dices.erase(tile_container.get_tile(dice[-1].x, dice[-1].y))
		else:
			path = point
			action = Action.RobotAction.Point
			if path:
				points.erase(tile_container.get_tile(point[-1].x, point[-1].y))
		
		if len(path) == 0:
			action = Action.RobotAction.End
			path = astar(starting_pos, Vector2i(0,3))
		
		if path == [starting_pos]:
			break
	
		actions.append(Action.new(action, path))
		starting_pos = path[-1]
	
	return actions

@onready var code_edit: CodeEdit = $"../MarginContainer/HFlowContainer/Code/HSplitContainer/CodeEdit"

enum Direction {
	Left,
	Right,
	Up,
	Down
}

func get_rotation_deg_from_direction(direction: Direction, inverted: bool = false) -> int:
	if inverted:
		var dir_int: int = int(direction)+1
		if dir_int <= 2:
			direction = Direction.Right if (dir_int % 2) else Direction.Left
		else:
			direction = Direction.Down if (dir_int % 4) else Direction.Up
	
	match direction:
		Direction.Up:
			return 0
		Direction.Down:
			return 180
		Direction.Left:
			return -90
		Direction.Right:
			return 90
	
	return 0

func get_move_forward_string(inverted: bool = false, times: int = 1) -> String:
	return "run(%s, %d);\n" % [inverted, times]

func get_run_until_black(inverted: bool = false) -> String:
	return "run_until_black(%s);\n" % [inverted]
		
func get_run_until_escape_blackhole(inverted: bool = false) -> String:
	return "run_until_escape_blackhole(%s);\n" % [inverted]

func update_actions() -> void:
	path_container.actions = generate_actions()
	
	var code: String = ""
	
	var rotation: int = 0
	var last_path = null
	var last_direction: Vector2i
	var to_move: int = 0
	
	var suggested_rotation: int = 0
	var backward: bool = false
	
	var deployed_dice: int = 0
	
	for action: Action in path_container.actions:
		var action_path: Array[Vector2i] = action.path
		var last_action_path: Vector2i = action.path[-1]
		
		for p in action_path:
			var tile: Tile = tile_container.get_tile(p.x, p.y)
			if last_path != null:
				var direction: Vector2i =  p - last_path
				var can_move_to_next_tile: bool = can_move(last_path.x, last_path.y, last_path.x + last_direction.x, last_path.y + last_direction.y, false) == IsMovable.Yes
				last_direction = direction
				
				if p == last_path:
					continue
				
				match direction:
					Vector2i(0, -1):
						suggested_rotation = get_rotation_deg_from_direction(Direction.Up, backward)
					Vector2i(0, 1):
						suggested_rotation = get_rotation_deg_from_direction(Direction.Down, backward)
					Vector2i(-1, 0):
						suggested_rotation = get_rotation_deg_from_direction(Direction.Left, backward)
					Vector2i(1, 0):
						suggested_rotation = get_rotation_deg_from_direction(Direction.Right, backward)

				var rotation_diff: int = (suggested_rotation - rotation)
				
				if rotation_diff == 0:
					to_move += 1
				elif rotation_diff < 180:
					if to_move:
						if !can_move_to_next_tile:
							code += get_run_until_black(backward)
						else:
							code += get_move_forward_string(backward, to_move)
						
					code += "rotate_right(%d);\n" % [suggested_rotation]
					to_move = 1
				else:
					if to_move:
						if !can_move_to_next_tile:
							code += get_run_until_black(backward)
						else:
							code += get_move_forward_string(backward, to_move)
						
					code += "rotate_left(%d);\n" % [suggested_rotation]
					to_move = 1
				
				if tile.obstacle.type == Obstacle.Type.bar:
					code += get_run_until_black(backward)
					code += get_run_until_escape_blackhole(backward)
					to_move = 0
				
				if last_action_path == p:
					if to_move:
						if !can_move_to_next_tile:
							code += get_run_until_black(backward)
						else:
							code += get_move_forward_string(backward, to_move)
					
					#var objective_tile: Tile = tile_container.get_tile(last_action_path.x, last_action_path.y)
					match action.action:
						Action.RobotAction.Dice:
							deployed_dice += 1
							if deployed_dice < 2:
								code += "deploy_dice_front();\n"
							else:
								code += "deploy_dice_back();\n"
								backward = true
								
					to_move = 0
				
			rotation = suggested_rotation
			last_path = p
		
		code += "\n"
	code_edit.text = code
