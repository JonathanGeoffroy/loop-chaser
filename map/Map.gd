extends Node2D

var map: MapModel


func _ready() -> void:
	map = MapGenerator.new().generate(42, 50, 10)
	display_lines()


func display_lines() -> void:
	var rng = RandomNumberGenerator.new()
	for line in map.lines:
		var new_line := Line2D.new()
		new_line.default_color = Color(rng.randf(), rng.randf(), rng.randf())
		new_line.add_point(line.start)
		new_line.add_point(line.end)
		add_child(new_line)
