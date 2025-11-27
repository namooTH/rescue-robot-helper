extends Control

@export var tile_size: Vector2 = Vector2(24, 24):
	set(size):
		tile_size = size
		if self.is_node_ready():
			update_tiles()
@export var margin: Vector2 = Vector2(5, 5):
	set(size):
		margin = size
		if self.is_node_ready():
			update_tiles()

signal updated(_tile)

var tile = preload("res://components/tile/tile.tscn")
var tiles = []

func resized():
	var parent = get_parent()
	if parent is AspectRatioContainer:
		parent.ratio = tile_size.x / tile_size.y
	else:
		disconnect("resized", resized)
		await get_tree().process_frame
		var min_tile_size_ratio = size.x / tile_size.x
		set_deferred("size", min_tile_size_ratio * tile_size)
		connect("resized", resized)
	update_tiles()

func _ready() -> void:
	self.connect("resized", resized)
	resized()

func save() -> RescueTilesFile:
	var saved_tiles = []
	for child in get_children():
		var tile_vec = child.name.split("-")
		tile_vec = Vector2i(int(tile_vec[0]), int(tile_vec[1]))
		var tile_property: TileProperty = TileProperty.new(tile_vec, child.height, child.wall, child.dice, child.obstacle, child.extra)
		saved_tiles.append(tile_property)
	
	return RescueTilesFile.new(tile_size, saved_tiles)

func load_from_rescue_tiles_file(rtf: RescueTilesFile):
	#tile_size = rtf.tile_size
	for t: TileProperty in rtf.tiles:
		var working_tile = get_tile(t.tile.x, t.tile.y)
		working_tile.height = t.height
		working_tile.wall = t.wall
		working_tile.dice = t.dice
		working_tile.obstacle = t.obstacle
		working_tile.extra = t.extra
		working_tile.update()

func reset():
	for child in get_children():
		var tile_vec = child.name.split("-")
		tile_vec = Vector2i(int(tile_vec[0]), int(tile_vec[1]))
		
		child.height = Height.new()
		child.wall = Wall.new()
		child.dice = Dice.new()
		child.obstacle = Obstacle.new()
		child.extra = Extra.new()
		
		if tile_vec.x == 0 and tile_vec.y == tile_size.y-1:
			child.extra.type = Extra.Type.start_stop
		
		child.update()

func update_tiles() -> void:
	var updated_tiles = []
	for x in range(tile_size.x):
		for y in range(tile_size.y):
			var node_name = str(x) + "-" + str(y)
			var working_tile = get_node_or_null(node_name)
			
			if !is_instance_valid(working_tile):
				working_tile = tile.instantiate()
				working_tile.connect("updated", _updated)
				
				add_child(working_tile)
				
				if x == 0 and y == tile_size.y-1:
					working_tile.extra.type = Extra.Type.start_stop
					working_tile.update()
				
				working_tile.name = node_name
				
			var applied_tile_size =  (size - margin) / tile_size
			working_tile.set_deferred("size", applied_tile_size)
			working_tile.set_deferred("position", Vector2(x * applied_tile_size.x, y * applied_tile_size.y) + margin / 2)
			
			updated_tiles.append(node_name)
			
	for child in get_children():
		if child.name not in updated_tiles:
			child.queue_free()

func get_tile(x: int, y: int):
	return get_node_or_null(str(x) + "-" + str(y))

func _updated(_tile):
	if _tile.extra.type == Extra.Type.start_stop:
		for child in get_children():
			if child != _tile and child.extra.type == Extra.Type.start_stop:
				child.extra.type = Extra.Type.none
				child.update()
	updated.emit(_tile)
