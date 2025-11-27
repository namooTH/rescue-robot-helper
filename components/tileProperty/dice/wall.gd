extends Resource
class_name Dice

enum Direction {
	left,
	right,
	up,
	down,
	none = -1
}

@export var direction: Direction = Direction.none
@export var color: Color = Color.GREEN

func _init(_direction := Direction.none, _color := Color.GREEN):
	direction = _direction
	color = _color
