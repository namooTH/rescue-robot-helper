extends Control

var current_tile:
	set(tile):
		show()
		current_tile = tile
		current_obstacle = current_tile.obstacle

var current_obstacle: Obstacle:
	set(obstacle):
		current_obstacle = obstacle
		$AspectRatioContainer/Wall/Floor/ObstacleRenderer.current_obstacle = obstacle
		$Type.selected = obstacle.type+1

func _ready() -> void:
	hide()
	$Type.connect("item_selected", type_selected)
	$Rotate.connect("pressed", rotated)

func type_selected(item):
	item -= 1
	current_obstacle.type = item
	$AspectRatioContainer/Wall/Floor/ObstacleRenderer.update()
	current_tile.update()

func rotated():
	current_obstacle.alignment = int(!bool(current_obstacle.alignment)) as Obstacle.Alignment
	$AspectRatioContainer/Wall/Floor/ObstacleRenderer.update()
	current_tile.update()
