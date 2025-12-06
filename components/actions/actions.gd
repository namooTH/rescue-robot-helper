class_name Action

enum RobotAction {
	End,
	Walk,
	Point,
	Dice
}

@export var action: RobotAction
@export var path: Array[Vector2i]

func _init(_action := RobotAction.Walk, _path := []):
	action = _action
	path = _path
