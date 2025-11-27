extends Resource
class_name RescueTilesFile

@export var tile_size: Vector2 = Vector2.ZERO
@export var tiles: Array = []

func _init(_tile_size := Vector2.ZERO, _tiles := []):
	tile_size = _tile_size
	tiles = _tiles
