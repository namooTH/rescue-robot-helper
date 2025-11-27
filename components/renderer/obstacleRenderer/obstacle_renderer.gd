extends Control

var current_tile:
	set(tile):
		current_tile = tile
		current_obstacle = current_tile.obstacle
		
var current_obstacle: Obstacle:
	set(obstacle):
		current_obstacle = obstacle
		update()
		
func update():
	for child in get_children():
		child.hide()
	match current_obstacle.type:
		Obstacle.Type.bar:
			match current_obstacle.alignment:
				Obstacle.Alignment.horizontal:
					$barH.show()
				Obstacle.Alignment.vertical:
					$barV.show()
		Obstacle.Type.chopstick:
			match current_obstacle.alignment:
				Obstacle.Alignment.horizontal:
					$chopstickH.show()
				Obstacle.Alignment.vertical:
					$chopstickV.show()
