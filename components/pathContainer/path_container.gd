extends Control
class_name PathContainer

@export var tile_container: TileContainer
var actions: Array[Action] = []:
	set(a):
		actions = a
		update_paths()

var path_render = preload("res://components/path/path.tscn")

func update_paths() -> void:
	for child in get_children():
		child.queue_free()
	
	for i in range(len(actions)):
		var a: Action = actions[i]
		var p: Path = path_render.instantiate()
		
		var ps: Array[Vector2] = []
		for action_path in a.path:
			var tile = tile_container.get_tile(action_path.x, action_path.y)
			var pos = tile.position + (tile.size / 2)
			ps.append(pos)
		
		p.points = ps
		p.hovered.connect(path_hovered)
		p.unhovered.connect(path_unhovered)
		
		#p.color = rainbow_from_zero_to_one(i/float(len(actions)))
		add_child(p)
		p.name = str(a)

var is_focusing: bool = false

func path_hovered(path: Path):
	if is_focusing:
		return
		
	for child in get_children():
		if child is Path and child != path:
			child.hide()
			
	is_focusing = true

func path_unhovered(_path: Path):
	for child in get_children():
		child.show()
		
	is_focusing = false
