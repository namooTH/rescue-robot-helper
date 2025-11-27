extends Control

var current_tile:
	set(tile):
		show()
		current_tile = tile
		current_height = current_tile.height

var current_height: Height:
	set(height):
		current_height = height
		$AspectRatioContainer/Wall/Floor/HeightRenderer.current_height = height
		$Surface.selected = height.surface
		update_checkboxes()
		
func _ready() -> void:
	hide()
	$Surface.connect("item_selected", surface_selected)
	$AspectRatioContainer/Wall/Floor/left.connect("toggled", left_toggled)
	$AspectRatioContainer/Wall/Floor/right.connect("toggled", right_toggled)
	$AspectRatioContainer/Wall/Floor/up.connect("toggled", up_toggled)
	$AspectRatioContainer/Wall/Floor/down.connect("toggled", down_toggled)

func surface_selected(item):
	current_height.surface = item
	$AspectRatioContainer/Wall/Floor/HeightRenderer.update()
	current_tile.update()

func update_checkboxes():
	$AspectRatioContainer/Wall/Floor/left.set_pressed_no_signal(current_height.direction == Height.Direction.left)
	$AspectRatioContainer/Wall/Floor/right.set_pressed_no_signal(current_height.direction == Height.Direction.right)
	$AspectRatioContainer/Wall/Floor/up.set_pressed_no_signal(current_height.direction == Height.Direction.up)
	$AspectRatioContainer/Wall/Floor/down.set_pressed_no_signal(current_height.direction == Height.Direction.down)

func left_toggled(toggled: bool):
	current_height.direction = Height.Direction.left if toggled else Height.Direction.none
	update_checkboxes()
	$AspectRatioContainer/Wall/Floor/HeightRenderer.update()
	current_tile.update()

func right_toggled(toggled: bool):
	current_height.direction = Height.Direction.right if toggled else Height.Direction.none
	update_checkboxes()
	$AspectRatioContainer/Wall/Floor/HeightRenderer.update()
	current_tile.update()

func up_toggled(toggled: bool):
	current_height.direction = Height.Direction.up if toggled else Height.Direction.none
	update_checkboxes()
	$AspectRatioContainer/Wall/Floor/HeightRenderer.update()
	current_tile.update()
	
func down_toggled(toggled: bool):
	current_height.direction = Height.Direction.down if toggled else Height.Direction.none
	update_checkboxes()
	$AspectRatioContainer/Wall/Floor/HeightRenderer.update()
	current_tile.update()
