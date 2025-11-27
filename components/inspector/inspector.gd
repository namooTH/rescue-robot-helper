extends Panel

var current_tile

var inspectHeight = preload("res://components/inspector/inspectHeight/inspectHeight.tscn")
var inspectWall = preload("res://components/inspector/inspectWall/inspectWall.tscn")
var inspectDice = preload("res://components/inspector/inspectDice/inspectDice.tscn")
var inspectObstacle = preload("res://components/inspector/inspectObstacle/inspectObstacle.tscn")
var inspectExtra = preload("res://components/inspector/inspectExtra/inspectExtra.tscn")

func _ready() -> void:
	SelectionManager.connect("on_selection", update)
	$VSplitContainer/TabBar.connect("tab_changed", tab_changed)

func tab_changed(tab: int):
	for child in $VSplitContainer/SettingContainer.get_children():
		child.queue_free()
		await child.tree_exited
	
	var tab_to_create
	match tab:
		0:
			tab_to_create = inspectHeight.instantiate()
		1:
			tab_to_create = inspectWall.instantiate()
		2:
			tab_to_create = inspectDice.instantiate()
		3:
			tab_to_create = inspectObstacle.instantiate()
		4:
			tab_to_create = inspectExtra.instantiate()
	
	if tab_to_create:
		$VSplitContainer/SettingContainer.add_child(tab_to_create)
		update_inspector()

func update(item):
	if current_tile != item:
		if current_tile:
			current_tile.disconnect("updated", tile_updated)
			
		current_tile = item
		current_tile.connect("updated", tile_updated)
	update_inspector()
	
func tile_updated(_tile):
	update_inspector()

func update_inspector():
	if $VSplitContainer/SettingContainer.get_child_count() == 0:
		$VSplitContainer/SettingContainer.add_child(inspectHeight.instantiate())
		
	if is_instance_valid(current_tile):
		$VSplitContainer/SettingContainer.get_child(0).current_tile = current_tile
