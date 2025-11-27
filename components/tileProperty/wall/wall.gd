extends Resource
class_name Wall

@export var left: bool = false
@export var right: bool = false
@export var up: bool = false
@export var down: bool = false

func _init(_left := false, _right := false, _up := false, _down := false):
	left = _left
	right = _right
	up = _up
	down = _down
