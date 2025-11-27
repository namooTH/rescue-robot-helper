extends Resource
class_name Extra

enum Type {
	point,
	start_stop,
	none = -1
}

enum Alignment {
	horizontal,
	vertical
}

@export var type: Type = Type.none
@export var alignment: Alignment = Alignment.horizontal

func _init(_type := Type.none, _alignment := Alignment.horizontal):
	type = _type
	alignment = _alignment
