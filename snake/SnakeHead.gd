class_name SnakeHead
extends Area2D

signal eated(food: Food)
signal tail_hitted(snakePart: SnakePart)


func on_colide(area: Area2D) -> void:
	if area.is_in_group("food"):
		var food: Food = area
		eated.emit(area)

	elif area.is_in_group("snakePart"):
		tail_hitted.emit(area)

	elif area.is_in_group("cursor"):
		get_tree().change_scene_to_file("res://GameOver/GameOver.tscn")
