extends Control

var current_tile:
	set(tile):
		current_tile = tile
		current_wall = current_tile.wall

var current_wall: Wall:
	set(wall):
		current_wall = wall
		update()

func update():
	$left.visible = current_wall.left
	$right.visible = current_wall.right
	$up.visible = current_wall.up
	$down.visible = current_wall.down
