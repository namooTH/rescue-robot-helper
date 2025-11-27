extends Resource
class_name Height

enum Surface {
	ground,
	above
}

enum Direction {
	left,
	right,
	up,
	down,
	none = -1
}

@export var surface: Surface = Surface.ground
@export var direction: Direction = Direction.none

func _init(_surface := Surface.ground, _direction := Direction.none):
	surface = _surface
	direction = _direction
