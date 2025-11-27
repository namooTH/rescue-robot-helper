extends Control

var current_tile:
	set(tile):
		show()
		current_tile = tile
		current_extra = current_tile.extra

var current_extra: Extra:
	set(extra):
		current_extra = extra
		$AspectRatioContainer/Wall/Floor/ExtraRenderer.current_extra = extra
		$Type.selected = extra.type+1

func _ready() -> void:
	hide()
	$Type.connect("item_selected", type_selected)
	$Rotate.connect("pressed", rotated)

func type_selected(item):
	item -= 1
	current_extra.type = item
	$AspectRatioContainer/Wall/Floor/ExtraRenderer.update()
	current_tile.update()

func rotated():
	current_extra.alignment = int(!bool(current_extra.alignment)) as Extra.Alignment
	$AspectRatioContainer/Wall/Floor/ExtraRenderer.update()
	current_tile.update()
