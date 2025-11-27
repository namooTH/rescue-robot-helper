extends Node

signal on_selection(item)

var selected:
	set(item):
		selected = item
		emit_signal("on_selection", item)
