extends Control

var current_tile:
	set(tile):
		current_tile = tile
		current_dice = current_tile.dice
		
var current_dice: Dice:
	set(dice):
		current_dice = dice
		update()
		
func update():
	for child in get_children():
		child.color = current_dice.color
		child.hide()
	match current_dice.direction:
		Dice.Direction.left:
			$left.show()
		Dice.Direction.right:
			$right.show()
		Dice.Direction.up:
			$up.show()
		Dice.Direction.down:
			$down.show()
