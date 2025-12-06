extends Control
class_name Path

@export var color: Color = Color.BLACK

@export var line_thickness := 20.0
@export var points: Array[Vector2] = []

@onready var path: Path2D = $Path2D
@onready var line: Line2D = $Path2D/Line2D

var base_size: Vector2
var base_curve: Curve2D

signal hovered
signal unhovered

func _ready() -> void:
	update()
	connect("resized", _on_resized)

func update():
	base_size = size
	base_curve = Curve2D.new()

	for p in points:
		base_curve.add_point(p)

	path.curve = base_curve

	line.default_color = color
	line.width = line_thickness
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND

	update_line_points()
	_update_button_positions()

var was_on_line: bool = false

func _input(_event: InputEvent) -> void:
	var on: bool = is_mouse_on_line()
	if on != was_on_line:
		if on:
			hovered.emit(self)
		else:
			unhovered.emit(self)
	
	was_on_line = on

func update_line_points():
	line.points.clear()
	for i in range(path.curve.get_point_count()):
		line.add_point(path.curve.get_point_position(i))

func _on_resized():
	var sc: Vector2 = size / base_size
	path.scale = sc
	line.width = line_thickness * ((sc.x + sc.y) * 0.5)
	
	_update_button_positions()

func _update_button_positions():
	if line.get_point_count() < 2:
		return

	var sc: Vector2 = size / base_size
	
	var head_pos = line.points[0] * sc
	var tail_pos = line.points[-1] * sc

	$head.position = head_pos - $head.size * 0.5
	$tail.position = tail_pos - $tail.size * 0.5

func is_mouse_on_line() -> bool:
	var sc: Vector2 = size / base_size

	var mouse_pos = get_local_mouse_position()

	for i in line.get_point_count() - 1:
		if _distance_point_to_segment(mouse_pos, line.points[i] * sc, line.points[i + 1] * sc) <= 12.0:
			return true

	return false

func _distance_point_to_segment(p: Vector2, a: Vector2, b: Vector2) -> float:
	var ab = b - a
	var ap = p - a
	var t = clamp(ab.dot(ap) / ab.length_squared(), 0.0, 1.0)
	var closest = a + ab * t
	return p.distance_to(closest)
