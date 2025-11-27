extends Resource
class_name TileProperty

@export var tile: Vector2i = Vector2i.ZERO

@export var height: Height = Height.new()
@export var wall: Wall = Wall.new()
@export var dice: Dice = Dice.new()
@export var obstacle: Obstacle = Obstacle.new()
@export var extra: Extra = Extra.new()

func _init(_tile := Vector2i.ZERO, _height := Height.new(), _wall := Wall.new(), _dice := Dice.new(), _obstacle := Obstacle.new(), _extra := Extra.new()):
	tile = _tile
	
	height = _height
	wall = _wall
	dice = _dice
	obstacle = _obstacle
	extra = _extra
