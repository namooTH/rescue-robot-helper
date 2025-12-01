extends Panel
class_name Tile

@export var height: Height = Height.new()
@export var wall: Wall = Wall.new()
@export var dice: Dice = Dice.new()
@export var obstacle: Obstacle = Obstacle.new()
@export var extra: Extra = Extra.new()

signal updated(tile)

func _ready() -> void:
	$Button.connect("pressed", pressed)
	update()
	
func pressed():
	SelectionManager.selected = self
	
func update():
	$WallRenderer.current_tile = self
	$DiceRenderer.current_tile = self
	$ObstacleRenderer.current_tile = self
	$ExtraRenderer.current_tile = self
	$HeightRenderer.current_tile = self
	emit_signal("updated", self)
