extends Control

@onready var tile_container = $MarginContainer/HFlowContainer/Editor/MarginContainer/HSplitContainer/AspectRatioContainer/TileContainer

var current_file
var is_saved: bool = true

func _ready() -> void:
	tile_container.connect("updated", updated)
	$MarginContainer/HFlowContainer/MenuBar/MarginContainer/HBoxContainer/HBoxContainer/MenuButton.get_popup().connect("id_pressed", menu_button_pressed)
	$MarginContainer/HFlowContainer/MenuBar/MarginContainer/HBoxContainer/TabBar.connect("tab_selected", tab_selected)
	
func tab_selected(tab: int):
	match tab:
		0:
			$MarginContainer/HFlowContainer/Editor.show()
			$MarginContainer/HFlowContainer/Actions.hide()
			$MarginContainer/HFlowContainer/Code.hide()
			var tc = get_node_or_null("MarginContainer/HFlowContainer/Actions/HSplitContainer/AspectRatioContainer")
			if tc:
				tc.reparent($MarginContainer/HFlowContainer/Editor/MarginContainer/HSplitContainer)
		1:
			$MarginContainer/HFlowContainer/Editor.hide()
			$MarginContainer/HFlowContainer/Actions.show()
			$MarginContainer/HFlowContainer/Code.hide()
			var tc = get_node_or_null("MarginContainer/HFlowContainer/Editor/MarginContainer/HSplitContainer/AspectRatioContainer")
			if tc:
				tc.reparent($MarginContainer/HFlowContainer/Actions/HSplitContainer)
		2:
			$MarginContainer/HFlowContainer/Editor.hide()
			$MarginContainer/HFlowContainer/Actions.hide()
			$MarginContainer/HFlowContainer/Code.show()
	
func menu_button_pressed(id: int):
	match id:
		0:
			tile_container.reset()
			current_file = null
			update()
		1:
			var vaild_id = randi()
			$FileDialog.set_meta("vaild_id", vaild_id)
			
			$FileDialog.file_mode = FileDialog.FileMode.FILE_MODE_OPEN_FILE
			$FileDialog.show()
			var path = await $FileDialog.file_selected
			
			if $FileDialog.get_meta("vaild_id") != vaild_id:
				return
				
			load_file(path)
		2:
			save_file()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("save"):
		save_file()

func load_file(path: String):
	var rescue_tiles_file: RescueTilesFile = ResourceLoader.load(path)
	tile_container.disconnect("updated", updated)
	tile_container.load_from_rescue_tiles_file(rescue_tiles_file)
	tile_container.connect("updated", updated)
	is_saved = true
	current_file = path

	update()

func save_file():
	var path
	if current_file:
		path = current_file
	else:
		var vaild_id = randi()
		$FileDialog.set_meta("vaild_id", vaild_id)
		
		$FileDialog.file_mode = FileDialog.FileMode.FILE_MODE_SAVE_FILE
		$FileDialog.show()
		path = await $FileDialog.file_selected
		
		if $FileDialog.get_meta("vaild_id") != vaild_id:
			return
			
	ResourceSaver.save(tile_container.save(), path)
	current_file = path
	is_saved = true
	update()

func update_path():
	if current_file:
		$MarginContainer/HFlowContainer/MenuBar/MarginContainer/HBoxContainer/Status/FileName.text = current_file.split("/")[-1].replace(".res", "")
		if !is_saved:
			$MarginContainer/HFlowContainer/MenuBar/MarginContainer/HBoxContainer/Status/NotSaved.show()
		else:
			$MarginContainer/HFlowContainer/MenuBar/MarginContainer/HBoxContainer/Status/NotSaved.hide()
	else:
		$MarginContainer/HFlowContainer/MenuBar/MarginContainer/HBoxContainer/Status/FileName.text = ""
		$MarginContainer/HFlowContainer/MenuBar/MarginContainer/HBoxContainer/Status/NotSaved.hide()

func updated(_tile):
	is_saved = false

func update():
	update_path()
	$pathfind.update_actions()
