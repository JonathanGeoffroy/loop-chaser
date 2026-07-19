class_name Food
extends Area2D


func _ready() -> void:
	var scale_factor := Globals.food_size / 128.0
	scale = Vector2(scale_factor, scale_factor)
