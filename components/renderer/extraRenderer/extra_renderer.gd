extends Control

var current_tile:
	set(tile):
		current_tile = tile
		current_extra = current_tile.extra
		
var current_extra: Extra:
	set(extra):
		current_extra = extra
		update()
		
func update():
	for child in get_children():
		child.hide()
	match current_extra.type:
		Extra.Type.point:
			$point.show()
		Extra.Type.start_stop:
			$start_stop.show()
