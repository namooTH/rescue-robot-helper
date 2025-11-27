extends Control

var current_tile:
	set(tile):
		current_tile = tile
		current_height = current_tile.height

var current_height: Height:
	set(height):
		current_height = height
		update()

func update():
	for child in get_children():
		child.hide()
		
	match current_height.surface:
		Height.Surface.above:
			match current_height.direction:
				Height.Direction.left:
					$slopeLeft.show()
				Height.Direction.right:
					$slopeRight.show()
				Height.Direction.up:
					$slopeUp.show()
				Height.Direction.down:
					$slopeDown.show()
				Height.Direction.none:
					$above.show()
