extends Control

var current_tile:
	set(tile):
		show()
		current_tile = tile
		current_dice = current_tile.dice

var current_dice: Dice:
	set(dice):
		current_dice = dice
		$AspectRatioContainer/Wall/Floor/DiceRenderer.current_dice = dice
		update_checkboxes()
		
func _ready() -> void:
	hide()
	$AspectRatioContainer/Wall/Floor/left.connect("toggled", left_toggled)
	$AspectRatioContainer/Wall/Floor/right.connect("toggled", right_toggled)
	$AspectRatioContainer/Wall/Floor/up.connect("toggled", up_toggled)
	$AspectRatioContainer/Wall/Floor/down.connect("toggled", down_toggled)
	
func update_checkboxes():
	$AspectRatioContainer/Wall/Floor/left.set_pressed_no_signal(current_dice.direction == Dice.Direction.left)
	$AspectRatioContainer/Wall/Floor/right.set_pressed_no_signal(current_dice.direction == Dice.Direction.right)
	$AspectRatioContainer/Wall/Floor/up.set_pressed_no_signal(current_dice.direction == Dice.Direction.up)
	$AspectRatioContainer/Wall/Floor/down.set_pressed_no_signal(current_dice.direction == Dice.Direction.down)

func left_toggled(toggled: bool):
	current_dice.direction = Dice.Direction.left if toggled else Dice.Direction.none
	update_checkboxes()
	$AspectRatioContainer/Wall/Floor/DiceRenderer.update()
	current_tile.update()

func right_toggled(toggled: bool):
	current_dice.direction = Dice.Direction.right if toggled else Dice.Direction.none
	update_checkboxes()
	$AspectRatioContainer/Wall/Floor/DiceRenderer.update()
	current_tile.update()

func up_toggled(toggled: bool):
	current_dice.direction = Dice.Direction.up if toggled else Dice.Direction.none
	update_checkboxes()
	$AspectRatioContainer/Wall/Floor/DiceRenderer.update()
	current_tile.update()
	
func down_toggled(toggled: bool):
	current_dice.direction = Dice.Direction.down if toggled else Dice.Direction.none
	update_checkboxes()
	$AspectRatioContainer/Wall/Floor/DiceRenderer.update()
	current_tile.update()
