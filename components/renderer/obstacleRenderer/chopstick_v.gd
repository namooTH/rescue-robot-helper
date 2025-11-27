extends Control

var spacing := 57
var bar_width := 40
var count := 7

func _draw():
	var natural_width = bar_width * count + spacing * (count - 1)

	var scale_factor = min(size.x / natural_width, 1.0)

	var scaled_bar_width = bar_width * scale_factor
	var scaled_spacing = spacing * scale_factor

	for i in range(count):
		var x = i * (scaled_bar_width + scaled_spacing)
		draw_rect(Rect2(x,0, scaled_bar_width, size.y), Color.from_rgba8(199, 136, 0, 255))
