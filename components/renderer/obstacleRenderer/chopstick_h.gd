extends Control

var spacing := 57
var bar_height := 40
var count := 7

func _draw():
	var natural_height = bar_height * count + spacing * (count - 1)

	var scale_factor = min(size.y / natural_height, 1.0)

	var scaled_bar_height = bar_height * scale_factor
	var scaled_spacing = spacing * scale_factor

	for i in range(count):
		var y = i * (scaled_bar_height + scaled_spacing)
		draw_rect(Rect2(0, y, size.x, scaled_bar_height), Color.from_rgba8(199, 136, 0, 255))
