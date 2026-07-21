class_name SnakeHead
extends Area2D

signal eated(food: Food)
signal tail_hitted(snakePart: SnakePart)


func on_colide(area: Area2D) -> void:
	if area.is_in_group("snakePart"):
		tail_hitted.emit(area)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("food"):
		var food: Food = body
		eated.emit(body)
