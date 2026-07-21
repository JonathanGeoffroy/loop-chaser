class_name Food
extends Area2D


func _ready() -> void:
	var scale_factor := Globals.food_size / 128.0
	scale = Vector2(scale_factor, scale_factor)


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("cursor"):
		var cursor: Cursor = area
		cursor.get_hit()
