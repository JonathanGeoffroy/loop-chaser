extends Node2D


func _ready() -> void:
	var scale_factor = Globals.part_size / 128.0
	scale = Vector2(scale_factor, scale_factor)
