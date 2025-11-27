extends Control

var current_tile:
	set(tile):
		show()
		current_tile = tile
		current_wall = current_tile.wall

var current_wall: Wall:
	set(wall):
		current_wall = wall
		$AspectRatioContainer/Wall/Floor/WallRenderer.current_wall = wall
		$AspectRatioContainer/Wall/Floor/left.set_pressed_no_signal(wall.left)
		$AspectRatioContainer/Wall/Floor/right.set_pressed_no_signal(wall.right)
		$AspectRatioContainer/Wall/Floor/up.set_pressed_no_signal(wall.up)
		$AspectRatioContainer/Wall/Floor/down.set_pressed_no_signal(wall.down)
		
		
func _ready() -> void:
	hide()
	$AspectRatioContainer/Wall/Floor/left.connect("toggled", left_toggled)
	$AspectRatioContainer/Wall/Floor/right.connect("toggled", right_toggled)
	$AspectRatioContainer/Wall/Floor/up.connect("toggled", up_toggled)
	$AspectRatioContainer/Wall/Floor/down.connect("toggled", down_toggled)
	
func left_toggled(toggled: bool):
	current_wall.left = toggled
	$AspectRatioContainer/Wall/Floor/WallRenderer.update()
	current_tile.update()

func right_toggled(toggled: bool):
	current_wall.right = toggled
	$AspectRatioContainer/Wall/Floor/WallRenderer.update()
	current_tile.update()

func up_toggled(toggled: bool):
	current_wall.up = toggled
	$AspectRatioContainer/Wall/Floor/WallRenderer.update()
	current_tile.update()
	
func down_toggled(toggled: bool):
	current_wall.down = toggled
	$AspectRatioContainer/Wall/Floor/WallRenderer.update()
	current_tile.update()
